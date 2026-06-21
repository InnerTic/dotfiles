#!/usr/bin/env bash
# ============================================================
# llama-loader — EXECUTION CORE
# Builds cmd, saves state, launches llama-server.
# Receives config via environment: SELECTED, CTX_SIZE, etc.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

migrate_legacy_state
assert_clean_state

SPLIT_ARG=""
[ -n "$TENSOR_SPLIT" ] && SPLIT_ARG="--split $TENSOR_SPLIT"

CMD=(
  "$LLAMA_SERVER"
  -m "$SELECTED"
  --host 0.0.0.0
  --port "$PORT"
  -ngl "$NGL"
  --ctx-size "$CTX_SIZE"
  $GPU_ARG
  $NP_ARG
  $SPLIT_ARG
)

save_state
exec "${CMD[@]}"
