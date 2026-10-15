#!/usr/bin/env bash
# ============================================================
# llama-loader — shared library
# Sourced by all scripts in the pipeline.
# ============================================================

shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_DIR="$HOME/Downloads/llm_models"
MODEL_STORAGE="$MODELS_DIR/model_storage"
SSD_DIR="$MODELS_DIR"
HDD_DIR="$MODEL_STORAGE"
LLAMA_SERVER="$HOME/infra/llama-server.sh"
STATE_DIR="$HOME/.config/llama-loader"
STATE_FILE="$STATE_DIR/state.json"
MODEL_STATE_DIR="$STATE_DIR/models"

# Multimodal projector / device placement (defaults; modes may override)
MMPROJ="${MMPROJ:-}"
MMPROJ_DEVICE="${MMPROJ_DEVICE:-}"
MMPROJ_DISABLED="${MMPROJ_DISABLED:-0}"
MODEL_DEVICE="${MODEL_DEVICE:-}"

ensure_state_dirs() {
  mkdir -p "$STATE_DIR" "$MODEL_STATE_DIR"
}

# --- JSON helpers (python3) ---
get_json_value() {
  if [ ! -f "$1" ]; then
    echo ""
    return 0
  fi
  python3 -c "import json; print(json.load(open('$1')).get('$2',''))" 2>/dev/null
}

get_state_value() {
  local val
  val=$(get_json_value "$STATE_FILE" "$1")
  reject_cli_syntax "$val" || { echo ""; return 1; }
  echo "$val"
}

get_profile_value() {
  if [ -z "$PROFILE_FILE" ]; then
    return 0
  fi
  local val
  val=$(get_json_value "$PROFILE_FILE" "$1")
  reject_cli_syntax "$val" || { echo ""; return 1; }
  echo "$val"
}

# ------------------------------------------------------------
# STRICT TYPE CONTRACT HELPERS
# ------------------------------------------------------------
reject_cli_syntax() {
  if echo "$1" | grep -qE "^-np|--| "; then
    echo "STATE ERROR: CLI syntax detected: '$1'" >&2
    return 1
  fi
  return 0
}

validate_int() {
  [[ "$1" =~ ^[0-9]+$ ]] || {
    echo "STATE ERROR: expected integer, got '$1'" >&2
    exit 1
  }
  echo "$1"
}

sanitize_split() {
  local v="$1"
  v="${v// /}"
  if [[ "$v" =~ ^[0-9]+,[0-9]+$ ]]; then
    echo "$v"
  else
    echo "ERROR: invalid GPU split format: $1" >&2
    return 1
  fi
}

sanitize_np() {
  local v="$1"
  if [[ "$v" =~ ^[0-9]+$ ]]; then
    echo "$v"
  else
    echo "ERROR: invalid NP value: $v" >&2
    return 1
  fi
}

validate_split() {
  local cleaned="${1// /}"
  # empty = single-GPU / single-device placement (valid)
  [ -z "$cleaned" ] && { echo ""; return 0; }
  [[ "$cleaned" =~ ^[0-9]+,[0-9]+$ ]] || {
    echo "STATE ERROR: invalid GPU split format '$1' (expected X,Y)" >&2
    exit 1
  }
  echo "$cleaned"
}

# ------------------------------------------------------------
# NP contract: state = integer ONLY, runtime = flexible
# ------------------------------------------------------------
resolve_np() {
  local raw
  raw=$(resolve_default "np" "1")
  reject_cli_syntax "$raw" || raw="1"

  if [[ "$raw" == "auto" ]]; then
    echo "auto"
    return
  fi

  validate_int "$raw"
}

# ------------------------------------------------------------
# State migration: convert legacy CLI syntax to raw values
# ------------------------------------------------------------
migrate_legacy_state() {
  for f in "$STATE_FILE" "$MODEL_STATE_DIR"/*.json; do
    [ -f "$f" ] || continue

    if grep -qE '"-np|--ngl|--port' "$f" 2>/dev/null; then
      echo "MIGRATING LEGACY STATE: $f" >&2

      python3 - <<EOF
import json, re

path = "$f"
data = json.load(open(path))

def clean(v):
    if isinstance(v, str) and v.startswith("-"):
        return "1"
    return v

for k in list(data.keys()):
    data[k] = clean(data[k])

json.dump(data, open(path, "w"), indent=2)
EOF
    fi
  done
}

# ------------------------------------------------------------
# Soft guard: recover from legacy state, then enforce
# ------------------------------------------------------------
assert_clean_state() {
  local dirty=0

  if grep -qE "(-np|-ngl|--port)" "$STATE_FILE" 2>/dev/null; then
    echo "WARNING: legacy CLI syntax detected in STATE_FILE — migrating" >&2
    dirty=1
  fi

  if [ -n "$PROFILE_FILE" ] && grep -qE "(-np|-ngl|--port)" "$PROFILE_FILE" 2>/dev/null; then
    echo "WARNING: legacy CLI syntax detected in PROFILE_FILE — migrating" >&2
    dirty=1
  fi

  if [ "$dirty" -eq 1 ]; then
    migrate_legacy_state
  fi
}

# ------------------------------------------------------------
# Memory hierarchy (sanitized pipeline, RULE 3+4)
# ------------------------------------------------------------
resolve_default() {
  local key="$1" fallback="$2"
  local model_val global_val
  model_val=$(get_profile_value "$key")
  global_val=$(get_state_value "last_$key")
  if [ -n "$model_val" ]; then echo "$model_val"
  elif [ -n "$global_val" ]; then echo "$global_val"
  else echo "$fallback"
  fi
}

# ------------------------------------------------------------
# Extra args: resolve from profile, fallback to empty array
# ------------------------------------------------------------
resolve_extra_args() {
  local profile_args=""
  if [ -n "$PROFILE_FILE" ] && [ -f "$PROFILE_FILE" ]; then
    profile_args=$(python3 -c "
import json, sys
try:
    d = json.load(open('$PROFILE_FILE'))
    args = d.get('extra_args', [])
    print(' '.join(args))
except: pass
" 2>/dev/null)
  fi

  if [ -n "$profile_args" ]; then
    # Convert space-separated back to array
    read -r -a EXTRA_ARGS <<< "$profile_args"
  else
    EXTRA_ARGS=()
  fi
}

# ------------------------------------------------------------
# Multimodal projector (mmproj) helpers
# ------------------------------------------------------------
is_mmproj_file() {
  case "$(basename "$1")" in
    *mmproj*.gguf|*mmproj*.GGUF) return 0 ;;
    *) return 1 ;;
  esac
}

# Base name of a projector file: "<base>.mmproj-<x>.gguf" -> "<base>".
# Handles ".mmproj", "-mmproj" and "_mmproj" separators.
mmproj_base_name() {
  local b
  b="$(basename "$1")"
  b="${b%.gguf}"; b="${b%.GGUF}"
  case "$b" in
    *.mmproj*) b="${b%%.mmproj*}" ;;
    *-mmproj*) b="${b%%-mmproj*}" ;;
    *_mmproj*) b="${b%%_mmproj*}" ;;
  esac
  printf '%s' "$b"
}

# Find an mmproj inside an explicit directory that matches the model stem.
# Matching is by base name so "<base>.<quant>.gguf" pairs with
# "<base>.mmproj-<x>.gguf" (llama.cpp convention). A lone generic
# "mmproj*.gguf" in the folder is used as a last resort.
find_mmproj_in_dir() {
  local dir="$1" model_stem="${2:-}" f base best="" best_len=-1 count=0 sole=""
  [ -d "$dir" ] || return 0
  for f in "$dir"/*mmproj*.gguf; do
    [ -f "$f" ] || continue
    count=$((count + 1)); sole="$f"
    base="$(mmproj_base_name "$f")"
    if [ -n "$model_stem" ] && [ -n "$base" ]; then
      case "$model_stem" in
        "$base"|"$base".*|"$base"-*|"$base"_*)
          if [ "${#base}" -gt "$best_len" ]; then
            best="$f"; best_len="${#base}"
          fi
          ;;
      esac
    fi
  done
  if [ -n "$best" ]; then printf '%s\n' "$best"; return 0; fi
  if [ "$count" -eq 1 ] && [ -z "$(mmproj_base_name "$sole")" ]; then
    printf '%s\n' "$sole"
  fi
  return 0
}

# Locate the projector shipped alongside a given model file.
find_mmproj_for_model() {
  local model_path="$1" dir stem
  [ -n "$model_path" ] || return 0
  dir="$(dirname "$model_path")"
  stem="$(basename "$model_path")"
  stem="${stem%.gguf}"; stem="${stem%.GGUF}"
  find_mmproj_in_dir "$dir" "$stem"
}

# Resolve the projector for the current model:
#   profile value (path or "off") > auto-detected sibling file > none.
resolve_mmproj() {
  local model_path="${1:-${SELECTED:-$MODEL_PATH}}"
  local profile_val=""
  if [ -n "$PROFILE_FILE" ] && [ -f "$PROFILE_FILE" ]; then
    profile_val=$(python3 -c "
import json
try:
    v = json.load(open('$PROFILE_FILE')).get('mmproj','')
    print(v if isinstance(v, str) else '')
except: pass
" 2>/dev/null)
  fi
  case "$profile_val" in
    none|off)
      return 0 ;;
    "")
      find_mmproj_for_model "$model_path" ;;
    *)
      if [ -f "$profile_val" ]; then
        printf '%s\n' "$profile_val"
      else
        find_mmproj_for_model "$model_path"
      fi ;;
  esac
}

# Default projector GPU. The RTX 3060 (CUDA0) runs the vision encoder
# faster than the P40, so it is the default unless overridden.
resolve_mmproj_device() {
  local v
  v=$(resolve_default "mmproj_device" "")
  printf '%s\n' "${v:-CUDA0}"
}

# Capability probe against the installed llama-server (cached per run).
declare -A __LLAMA_FLAG_CACHE 2>/dev/null || true
llama_supports_flag() {
  local flag="$1"
  local cached="${__LLAMA_FLAG_CACHE[$flag]:-}"
  if [ "$cached" = "1" ]; then return 0; fi
  if [ "$cached" = "0" ]; then return 1; fi
  if [ -x "$LLAMA_SERVER" ] && "$LLAMA_SERVER" --help 2>/dev/null | grep -q -- "$flag"; then
    __LLAMA_FLAG_CACHE[$flag]=1
    return 0
  fi
  __LLAMA_FLAG_CACHE[$flag]=0
  return 1
}

# --- Model listing (colorized, storage-aware) ---
# Scans the SSD/HDD roots plus one level of subdirectories (VL bundles
# keep the model + mmproj together in their own folder). mmproj files
# are never selectable; models that have a sibling projector are [VL].
list_models() {
  MODELS=()
  local entry root tag d m
  for entry in "SSD:$SSD_DIR" "HDD:$HDD_DIR"; do
    tag="${entry%%:*}"
    root="${entry#*:}"
    [ -d "$root" ] || continue

    for m in "$root"/*.gguf; do
      [ -f "$m" ] || continue
      is_mmproj_file "$m" && continue
      MODELS+=("$tag:$m")
    done

    for d in "$root"/*/; do
      [ -d "$d" ] || continue
      d="${d%/}"
      # Skip symlinked dirs (e.g. model_storage -> /mnt/data, which the
      # HDD pass already covers) so models are listed exactly once.
      [ -L "$d" ] && continue
      for m in "$d"/*.gguf; do
        [ -f "$m" ] || continue
        is_mmproj_file "$m" && continue
        MODELS+=("$tag:$m")
      done
    done
  done

  if [ ${#MODELS[@]} -eq 0 ]; then
    echo "No .gguf models found"
    exit 1
  fi

  echo
  echo "================ MODEL INDEX ================"
  echo
  INDEX=1
  for i in "${!MODELS[@]}"; do
    local path size label rel mmproj_mark
    tag="${MODELS[$i]%%:*}"
    path="${MODELS[$i]#*:}"
    if [ "$tag" = "SSD" ]; then
      root="$SSD_DIR"
      label="\e[1;32mSSD FAST\e[0m"
    else
      root="$HDD_DIR"
      label="\e[1;31mHDD SLOW\e[0m"
    fi
    rel="${path#"$root"/}"
    size=$(du -h "$path" | cut -f1)
    if [ -n "$(find_mmproj_for_model "$path")" ]; then
      mmproj_mark="\e[1;35m[VL]\e[0m"
    else
      mmproj_mark=""
    fi
    printf "\e[90m%2s)\e[0m  \e[1m%-58s\e[0m  \e[36m(%-4s)\e[0m  %b  %b\n" \
      "$INDEX" "$rel" "$size" "$label" "$mmproj_mark"
    INDEX=$((INDEX+1))
  done
  echo
  echo "============================================"
  echo
}

select_model() {
  local choice
  read -p "Select model [1-${#MODELS[@]}]: " choice || true
  if [ -z "$choice" ] || ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#MODELS[@]}" ]; then
    echo "Invalid selection" >&2
    exit 1
  fi
  local raw="${MODELS[$((choice-1))]}"
  MODEL_LOCATION="${raw%%:*}"
  SELECTED="${raw#*:}"
  MODEL_NAME=$(basename "$SELECTED")
  PROFILE_FILE="$MODEL_STATE_DIR/${MODEL_NAME}.json"
  if [ ! -f "$PROFILE_FILE" ]; then
    echo "{}" > "$PROFILE_FILE"
  fi

  REASONING=$(resolve_reasoning_default)

  # Auto-attach a multimodal projector if one ships with the model.
  MMPROJ="$(resolve_mmproj "$SELECTED")"
  if [ -n "$MMPROJ" ]; then
    MMPROJ_DEVICE="$(resolve_mmproj_device)"
  else
    MMPROJ_DEVICE=""
  fi
}

# ------------------------------------------------------------
# Model-aware reasoning default
# ------------------------------------------------------------
resolve_reasoning_default() {
  local model_val
  model_val=$(get_profile_value "reasoning")
  if [ -n "$model_val" ]; then
    echo "$model_val"
    return
  fi
  if [[ "$MODEL_NAME" == *gemma*4* ]]; then
    echo "off"
  else
    echo "on"
  fi
}

# --- Preflight snapshot ---
show_snapshot() {
  local mode_label="${1:-CUSTOM}"

  local reason_display reason_color
  if [ "$REASONING" = "off" ]; then
    reason_display="OFF"
    reason_color="\033[33m"
  else
    reason_display="ON"
    reason_color="\033[32m"
  fi

  echo
  echo "===================================================="
  echo "PRE-FLIGHT SNAPSHOT  [$mode_label]"
  echo "===================================================="
  echo "MODEL: $MODEL_NAME"
  echo
  echo "STORAGE:"
  if [ "$MODEL_LOCATION" = "SSD" ]; then
    echo -e "  \e[32mSSD\e[0m-backed model (fast load)"
  else
    echo -e "  \e[31mHDD\e[0m-backed model (slow load)"
    echo -e "  \e[31mWarning: expect slower cold start (model load bottleneck)\e[0m"
  fi
  echo
  echo "GPU:"
  if [ -n "$MODEL_DEVICE" ]; then
    echo "  Single device  |  DEVICE: $MODEL_DEVICE"
  elif [ -n "$TENSOR_SPLIT" ]; then
    local display_split="${TENSOR_SPLIT//,/\/}"
    echo "  Dual GPU  |  SPLIT: $display_split"
  else
    echo "  Single GPU"
  fi

  if [ -n "$MMPROJ" ]; then
    echo
    echo "MULTIMODAL (mmproj):"
    echo "  file:    $(basename "$MMPROJ")"
    case "$MMPROJ_DEVICE" in
      ""|none|cpu|CPU|off)
        echo "  device:  CPU (no offload)" ;;
      *)
        echo "  device:  $MMPROJ_DEVICE" ;;
    esac
  fi
  echo
  echo "CONTEXT: $CTX_SIZE  |  NP: $NP_VAL  |  NGL: $NGL  |  PORT: $PORT"
  echo -e "REASONING: ${reason_color}${reason_display}${N}"

  if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    echo "EXTRA ARGS: ${EXTRA_ARGS[*]}"
  fi

  if [[ -n "$MCP_CONFIG" ]]; then
    echo "MCP TOOLS: enabled ($MCP_CONFIG)"
  fi

  # Show actual compiled CLI command
  echo
  echo "CLI:"
  echo "  llama-server"
  printf "  -m \"...gguf\""
  printf " --ctx-size %s" "$CTX_SIZE"
  printf " -ngl %s" "$NGL"
  printf " -np %s" "$NP_VAL"
  if [ -n "$MODEL_DEVICE" ]; then
    printf " --device %s" "$MODEL_DEVICE"
  else
    [ -n "$TENSOR_SPLIT" ] && printf " --tensor-split %s" "$TENSOR_SPLIT"
    printf " --main-gpu %s" "$MAIN_GPU"
  fi
  printf " --port %s" "$PORT"
  [ "$REASONING" = "off" ] && printf " --reasoning off"
  if [[ -n "$MMPROJ" && -f "$MMPROJ" ]]; then
    printf " --mmproj \"%s\"" "$(basename "$MMPROJ")"
    case "$MMPROJ_DEVICE" in
      none|cpu|CPU|off) printf " --no-mmproj-offload" ;;
      "") : ;;
      *) printf " --mmproj-device %s" "$MMPROJ_DEVICE" ;;
    esac
  fi
  if [[ -n "$MCP_CONFIG" && -f "$MCP_CONFIG" ]]; then
    printf " --mcp-servers-config %s" "$MCP_CONFIG"
    printf " --tools all"
  fi
  if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    printf " %s" "${EXTRA_ARGS[*]}"
  fi
  echo
  echo

  echo "INTERPRETATION:"
  if [ "$CTX_SIZE" -ge 131072 ]; then
    echo "  -> Long-context / high VRAM mode"
  else
    echo "  -> Standard inference mode"
  fi
  if [[ "$NP_VAL" == "auto" ]]; then
    echo "  -> Auto concurrency scheduling enabled"
  elif [ "$NP_VAL" -ge 4 ] 2>/dev/null; then
    echo "  -> High parallel load (VRAM pressure expected)"
  fi
  if [ "$TENSOR_SPLIT" = "20,80" ]; then
    echo "  -> P40-heavy GPU distribution"
  elif [ "$TENSOR_SPLIT" = "30,70" ]; then
    echo "  -> Balanced GPU distribution"
  fi
  if [ -n "$MMPROJ" ]; then
    case "$MMPROJ_DEVICE" in
      ""|none|cpu|CPU|off)
        echo "  -> Vision/multimodal projector attached (CPU)" ;;
      *)
        echo "  -> Vision/multimodal projector attached (encoder on $MMPROJ_DEVICE)" ;;
    esac
  fi
  echo
  echo "DRIFT CHECK:"
  local last_ctx last_split
  last_ctx=$(get_profile_value "ctx")
  last_split=$(get_profile_value "split")
  if [ -n "$last_ctx" ] && [ "$last_ctx" != "$CTX_SIZE" ]; then
    echo "  - Context: $last_ctx -> $CTX_SIZE"
  fi
  if [ -n "$last_split" ] && [ "$last_split" != "$TENSOR_SPLIT" ]; then
    echo "  - Split: $last_split -> $TENSOR_SPLIT"
  fi
  if [ -z "$last_ctx" ]; then
    echo "  - No prior run for this model"
  fi
}

# --- Decision gate ---
decision_gate() {
  local reason_display reason_color
  if [ "$REASONING" = "off" ]; then
    reason_display="OFF"
    reason_color="\033[33m"
  else
    reason_display="ON"
    reason_color="\033[32m"
  fi

  echo
  echo -e "[Enter] launch | [t] thinking (${reason_color}${reason_display}\033[0m) | [m] mmproj | [e] edit | [x] extra args | [c] cancel"
  read -r -t 10 decision || true
  [ -z "$decision" ] && decision="launch"

  case "$decision" in
    c) echo "Cancelled"; exit 0 ;;
    e) echo "Edit requested — re-run with custom mode"; exit 0 ;;
    x)
      source "$SCRIPT_DIR/builder/extra-args.sh"
      edit_extra_args
      show_snapshot "${1:-CUSTOM}"
      decision_gate "${1:-CUSTOM}"
      return
      ;;
    t)
      if [ "$REASONING" = "off" ]; then
        REASONING="on"
      else
        REASONING="off"
      fi
      show_snapshot "${1:-CUSTOM}"
      decision_gate "${1:-CUSTOM}"
      return
      ;;
    m)
      source "$SCRIPT_DIR/builder/mmproj.sh"
      edit_mmproj
      show_snapshot "${1:-CUSTOM}"
      decision_gate "${1:-CUSTOM}"
      return
      ;;
    launch|"") echo "Launching..." ;;
  esac
}

# --- State persistence ---
save_state() {
  assert_clean_state

  # HARD SANITIZATION: refuse to write CLI syntax to state
  if echo "$NP_VAL" | grep -qE "^-np|--"; then
    echo "STATE ERROR: refusing to write CLI syntax to state: '$NP_VAL'" >&2
    exit 1
  fi

  # "auto" is runtime-only — store fallback integer
  local np_store
  if [[ "$NP_VAL" == "auto" ]]; then
    np_store="1"
  else
    np_store="$NP_VAL"
  fi

  # Build extra_args JSON array
  local extra_json="[]"
  if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    extra_json=$(python3 -c "
import json, sys
args = sys.argv[1:]
print(json.dumps(args))
" "${EXTRA_ARGS[@]}" 2>/dev/null || echo "[]")
  fi

  # Projector: store the path, or "off" when explicitly disabled
  local mmproj_store="${MMPROJ:-}"
  [ "${MMPROJ_DISABLED:-0}" = "1" ] && mmproj_store="off"

  cat > "$PROFILE_FILE" <<EOF
{
  "schema_version": 4,
  "ctx": "$(validate_int "$CTX_SIZE")",
  "split": "$(validate_split "$TENSOR_SPLIT")",
  "ngl": "$(validate_int "$NGL")",
  "np": "$(validate_int "$np_store")",
  "port": "$(validate_int "$PORT")",
  "gpu_mode": "${GPU_MODE:-3}",
  "np_mode": "${NP_MODE:-manual}",
  "reasoning": "$REASONING",
  "mmproj": "$mmproj_store",
  "mmproj_device": "$MMPROJ_DEVICE",
  "model_device": "${MODEL_DEVICE:-}",
  "extra_args": $extra_json
}
EOF
  cat > "$STATE_FILE" <<EOF
{
  "schema_version": 4,
  "last_model": "$MODEL_NAME",
  "last_model_path": "$SELECTED",
  "last_ctx": "$(validate_int "$CTX_SIZE")",
  "last_split": "$(validate_split "$TENSOR_SPLIT")",
  "last_ngl": "$(validate_int "$NGL")",
  "last_np": "$(validate_int "$np_store")",
  "last_port": "$(validate_int "$PORT")",
  "last_location": "$MODEL_LOCATION",
  "last_gpu_mode": "${GPU_MODE:-3}",
  "last_np_mode": "${NP_MODE:-manual}",
  "last_reasoning": "$REASONING",
  "last_mmproj": "$mmproj_store",
  "last_mmproj_device": "$MMPROJ_DEVICE",
  "last_model_device": "${MODEL_DEVICE:-}",
  "last_extra_args": $extra_json
}
EOF
}
