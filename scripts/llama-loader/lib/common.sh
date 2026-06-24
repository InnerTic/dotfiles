# ============================================================
# llama-loader — shared library
# Sourced by all scripts in the pipeline.
# ============================================================
#
# SYSTEM INTEGRITY CONTRACT
# RULES:
# 1. State = raw values only (no CLI syntax ever stored)
# 2. CLI flags are derived at runtime only
# 3. NP is integer OR "auto" at runtime only
# 4. All state writes must pass validation functions
# 5. Any CLI syntax in state = hard failure
# 6. No silent normalization allowed
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

# --- Model listing (colorized, storage-aware) ---
list_models() {
  MODELS=()
  for m in "$SSD_DIR"/*.gguf; do
    [ -f "$m" ] && MODELS+=("SSD:$m")
  done
  for m in "$HDD_DIR"/*.gguf; do
    [ -f "$m" ] && MODELS+=("HDD:$m")
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
    local tag path name size label
    tag="${MODELS[$i]%%:*}"
    path="${MODELS[$i]#*:}"
    name=$(basename "$path")
    size=$(du -h "$path" | cut -f1)
    if [ "$tag" = "SSD" ]; then
      label="\e[32mSSD FAST\e[0m"
    else
      label="\e[31mHDD SLOW\e[0m"
    fi
    printf "\e[90m%2s)\e[0m  \e[1m%-65s\e[0m  \e[36m(%-4s)\e[0m  %s\n" \
      "$INDEX" "$name" "$size" "$label"
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
}

# --- Preflight snapshot ---
show_snapshot() {
  local mode_label="${1:-CUSTOM}"
  echo
  echo "===================================================="
  echo "PRE-FLIGHT SNAPSHOT  [$mode_label]"
  echo "===================================================="
  echo "MODEL: $MODEL_NAME"
  echo
  echo "STORAGE:"
  if [ "$MODEL_LOCATION" = "SSD" ]; then
    echo "  SSD-backed model (fast load)"
  else
    echo "  HDD-backed model (slow load)"
  fi
  if [ "$MODEL_LOCATION" = "HDD" ]; then
    echo "  Warning: expect slower cold start (model load bottleneck)"
  fi
  echo
  echo "GPU:"
  if [ -n "$TENSOR_SPLIT" ]; then
    local display_split="${TENSOR_SPLIT//,/\/}"
    echo "  Dual GPU  |  SPLIT: $display_split"
  else
    echo "  Single GPU"
  fi
  echo
  echo "CONTEXT: $CTX_SIZE  |  NP: $NP_VAL  |  NGL: $NGL  |  PORT: $PORT"
  local cli_line="CLI:  -np $NP_VAL  |  -ngl $NGL  |  --port $PORT"
  [ -n "$TENSOR_SPLIT" ] && cli_line+="  |  --tensor-split $TENSOR_SPLIT"
  echo "$cli_line"
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
  echo
  echo "[Enter] launch | [e] edit | [c] cancel"
  read -r -t 10 decision || true
  [ -z "$decision" ] && decision="launch"
  case "$decision" in
    c) echo "Cancelled"; exit 0 ;;
    e) echo "Edit requested — re-run with custom mode"; exit 0 ;;
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

  cat > "$PROFILE_FILE" <<EOF
{
  "schema_version": 2,
  "ctx": "$(validate_int "$CTX_SIZE")",
  "split": "$(validate_split "$TENSOR_SPLIT")",
  "ngl": "$(validate_int "$NGL")",
  "np": "$(validate_int "$np_store")",
  "port": "$(validate_int "$PORT")",
  "gpu_mode": "${GPU_MODE:-3}",
  "np_mode": "${NP_MODE:-manual}"
}
EOF
  cat > "$STATE_FILE" <<EOF
{
  "schema_version": 2,
  "last_model": "$MODEL_NAME",
  "last_ctx": "$(validate_int "$CTX_SIZE")",
  "last_split": "$(validate_split "$TENSOR_SPLIT")",
  "last_ngl": "$(validate_int "$NGL")",
  "last_np": "$(validate_int "$np_store")",
  "last_port": "$(validate_int "$PORT")",
  "last_location": "$MODEL_LOCATION",
  "last_gpu_mode": "${GPU_MODE:-3}",
  "last_np_mode": "${NP_MODE:-manual}"
}
EOF
}
