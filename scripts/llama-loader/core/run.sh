#!/usr/bin/env bash
# ============================================================
# llama-loader — EXECUTION CORE
# Builds cmd, saves state, launches llama-server.
# Receives config via environment: MODEL_PATH, CTX_SIZE, etc.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

CMD=(
  "$LLAMA_SERVER"
  -m "$SELECTED"
  --host 0.0.0.0
  --port "$PORT"
  -ngl "$NGL"
  --ctx-size "$CTX_SIZE"
  $GPU_ARG
  $NP_ARG
)

[ -n "$TENSOR_SPLIT" ] && CMD+=( --tensor-split "$TENSOR_SPLIT" )

save_state
exec "${CMD[@]}"
