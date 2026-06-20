#!/usr/bin/env bash
# ============================================================
# llama-loader — EXECUTION CORE
# Sources the IR contract, compiles CLI via dialect,
# asserts no flag leaks, saves state, launches.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/core/execution_plan.sh"

ensure_state_dirs
migrate_legacy_state
assert_clean_state

# Populate MODEL_PATH from SELECTED (set by mode script)
MODEL_PATH="$SELECTED"

# ------------------------------------------------------------
# SAFETY ASSERTION — prevents IR→CLI flag leaks
# ------------------------------------------------------------
assert_no_cli_leak() {
  local ir_vars="NP_VAL NGL CTX_SIZE TENSOR_SPLIT MAIN_GPU PORT"
  for var in $ir_vars; do
    local val="${!var}"
    if echo "$val" | grep -qE '^-{1,2}[a-z]'; then
      echo "ERROR: IR leak detected in $var='$val' — contains CLI flag syntax" >&2
      exit 1
    fi
  done
}

assert_no_cli_leak

# Compile CLI from IR
source "$SCRIPT_DIR/core/dialects/llama.cpp.sh"
CLI_ARGS=$(compile_cli)

# Final safety: reject any --np in compiled output
if echo "$CLI_ARGS" | grep -q -- '--np'; then
  echo "ERROR: dialect compiler emitted --np (should be -np)" >&2
  exit 1
fi

save_state

eval "exec \"\$LLAMA_SERVER\" $CLI_ARGS"
