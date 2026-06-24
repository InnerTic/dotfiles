#!/usr/bin/env bash
# ============================================================
# MODE: Factory Default
# Hardcoded safe baseline — no state dependency.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

assert_clean_state

list_models
select_model

CTX_SIZE=8192
TENSOR_SPLIT="30,70"
NGL=60
NP_VAL=1
NP_MODE=manual
MAIN_GPU=0
PORT=8080

show_snapshot "FACTORY DEFAULT"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
