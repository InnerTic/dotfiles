#!/usr/bin/env bash
# ============================================================
# llama-loader — EXECUTION CORE
# Builds cmd via IR → CLI dialect compiler, saves state,
# launches llama-server.
# Receives config via environment: SELECTED, CTX_SIZE, etc.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

migrate_legacy_state
assert_clean_state

# Map mode variables to IR contract
MODEL_PATH="$SELECTED"
MAIN_GPU="${MAIN_GPU:-0}"

# Compile IR → CLI flags via dialect compiler
source "$SCRIPT_DIR/core/dialects/llama.cpp.sh"
compile_cli

save_state
exec "${CMD[@]}"
