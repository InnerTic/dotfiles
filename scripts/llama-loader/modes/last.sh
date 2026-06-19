#!/usr/bin/env bash
# ============================================================
# MODE: Last Used
# Loads last successful config from state and launches.
# Only works if a prior run exists.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

MODEL_NAME=$(get_state_value "last_model")
if [ -z "$MODEL_NAME" ]; then
  echo "No prior run found — use factory or custom mode first."
  exit 1
fi

SELECTED="$SSD_DIR/$MODEL_NAME"
if [ ! -f "$SELECTED" ]; then
  SELECTED="$HDD_DIR/$MODEL_NAME"
fi
if [ ! -f "$SELECTED" ]; then
  echo "Model file not found: $MODEL_NAME"
  echo "Searching for matching model..."
  MODELS=()
  for m in "$SSD_DIR"/*.gguf; do [ -f "$m" ] && MODELS+=("$m"); done
  for m in "$HDD_DIR"/*.gguf; do [ -f "$m" ] && MODELS+=("$m"); done
  for m in "${MODELS[@]}"; do
    if [[ "$(basename "$m")" == "$MODEL_NAME" ]]; then
      SELECTED="$m"
      break
    fi
  done
fi
if [ ! -f "$SELECTED" ]; then
  echo "Could not locate $MODEL_NAME — select manually via factory or custom mode."
  exit 1
fi

if [[ "$SELECTED" == "$SSD_DIR"* ]]; then
  MODEL_LOCATION="SSD"
else
  MODEL_LOCATION="HDD"
fi

PROFILE_FILE="$MODEL_STATE_DIR/${MODEL_NAME}.json"
[ ! -f "$PROFILE_FILE" ] && echo "{}" > "$PROFILE_FILE"

CTX_SIZE=$(resolve_default "ctx" "8192")
TENSOR_SPLIT=$(resolve_default "split" "")
NGL=$(resolve_default "ngl" "60")
NP_ARG=$(resolve_default "np" "-np 1")
PORT=$(resolve_default "port" "8080")
GPU_ARG="--main-gpu 0"

[ -n "$TENSOR_SPLIT" ] && GPU_ARG="--main-gpu 0"

show_snapshot "LAST USED"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
