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

migrate_legacy_state

MODEL_NAME=$(get_state_value "last_model")
if [ -z "$MODEL_NAME" ]; then
  echo "No prior run found — use factory or custom mode first."
  exit 1
fi

# Prefer the exact path recorded last run (handles subdirectories/VL bundles)
SELECTED="$(get_json_value "$STATE_FILE" "last_model_path")"
if [ -z "$SELECTED" ] || [ ! -f "$SELECTED" ]; then
  SELECTED="$SSD_DIR/$MODEL_NAME"
fi
if [ ! -f "$SELECTED" ]; then
  SELECTED="$HDD_DIR/$MODEL_NAME"
fi
if [ ! -f "$SELECTED" ]; then
  echo "Model file not found: $MODEL_NAME"
  echo "Searching for matching model..."
  MODELS=()
  for m in "$SSD_DIR"/*.gguf "$SSD_DIR"/*/*.gguf "$HDD_DIR"/*.gguf "$HDD_DIR"/*/*.gguf; do
    [ -f "$m" ] && ! is_mmproj_file "$m" && MODELS+=("$m")
  done
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

if [[ "$SELECTED" == "$HDD_DIR"* || "$SELECTED" == *"/model_storage/"* ]]; then
  MODEL_LOCATION="HDD"
else
  MODEL_LOCATION="SSD"
fi

PROFILE_FILE="$MODEL_STATE_DIR/${MODEL_NAME}.json"
[ ! -f "$PROFILE_FILE" ] && echo "{}" > "$PROFILE_FILE"

assert_clean_state

CTX_SIZE=$(resolve_default "ctx" "8192")
TENSOR_SPLIT=$(resolve_default "split" "")
NGL=$(resolve_default "ngl" "60")

PORT=$(resolve_default "port" "8080")
GPU_MODE=$(resolve_default "gpu_mode" "3")

# --- NP SAFE LOAD (STATE → SANITIZE → CLI) ---

NP_RAW=$(resolve_default "np" "1")

# Detect legacy CLI contamination (-np, --np, etc.)
if echo "$NP_RAW" | grep -q -- "-np"; then
  echo "STATE CORRUPTION DETECTED: CLI syntax in NP value: $NP_RAW" >&2
  NP_RAW="1"
fi

# Strict integer validation (hard gate)
NP_VAL="$(sanitize_np "$NP_RAW" 2>/dev/null || echo "1")"

# CLI derivation (runtime only — used by dialect compiler)
MAIN_GPU="${MAIN_GPU:-0}"

# --- REASONING (from profile/state) ---
REASONING=$(resolve_default "reasoning" "on")

# --- MULTIMODAL PROJECTOR (from profile/state, else auto-detect) ---
MMPROJ=$(resolve_default "mmproj" "")
case "$MMPROJ" in
  off|none)
    MMPROJ="" ;;
  "")
    MMPROJ="$(find_mmproj_for_model "$SELECTED")" ;;
  *)
    [ -f "$MMPROJ" ] || MMPROJ="$(find_mmproj_for_model "$SELECTED")" ;;
esac
if [ -n "$MMPROJ" ]; then
  MMPROJ_DEVICE=$(resolve_default "mmproj_device" "")
  [ -z "$MMPROJ_DEVICE" ] && MMPROJ_DEVICE="CUDA0"
else
  MMPROJ_DEVICE=""
fi

# --- MODEL DEVICE (single-GPU pin) ---
MODEL_DEVICE=$(resolve_default "model_device" "")

# --- EXTRA ARGS (from profile) ---
resolve_extra_args

show_snapshot "LAST USED"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
