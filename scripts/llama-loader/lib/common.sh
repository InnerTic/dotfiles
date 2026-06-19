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
LLAMA_SERVER="$HOME/dotfiles/scripts/llama-server.sh"
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
  get_json_value "$STATE_FILE" "$1"
}

get_profile_value() {
  if [ -z "$PROFILE_FILE" ]; then
    return 0
  fi
  get_json_value "$PROFILE_FILE" "$1"
  return 0
}

# --- Memory hierarchy ---
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
    echo "  Dual GPU  |  SPLIT: $TENSOR_SPLIT"
  else
    echo "  Single GPU"
  fi
  echo
  echo "CONTEXT: $CTX_SIZE  |  NP: $NP_ARG  |  NGL: $NGL  |  PORT: $PORT"
  echo
  echo "INTERPRETATION:"
  if [ "$CTX_SIZE" -ge 131072 ]; then
    echo "  -> Long-context / high VRAM mode"
  else
    echo "  -> Standard inference mode"
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
  cat > "$PROFILE_FILE" <<EOF
{
  "ctx": "$CTX_SIZE",
  "split": "$TENSOR_SPLIT",
  "ngl": "$NGL",
  "np": "$(echo "$NP_ARG" | sed 's/^-np //')",
  "port": "$PORT",
  "gpu_mode": "${GPU_MODE:-3}"
}
EOF
  cat > "$STATE_FILE" <<EOF
{
  "last_model": "$MODEL_NAME",
  "last_ctx": "$CTX_SIZE",
  "last_split": "$TENSOR_SPLIT",
  "last_ngl": "$NGL",
  "last_port": "$PORT",
  "last_location": "$MODEL_LOCATION",
  "last_gpu_mode": "${GPU_MODE:-3}"
}
EOF
}
