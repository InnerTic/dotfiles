#!/usr/bin/env bash
# ============================================================
# MODE: Custom
# Interactive builder pipeline — prompts for every domain.
# Runs introspection after config is resolved.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

assert_clean_state

list_models
select_model

# Run builder modules (each sources into current shell)
source "$SCRIPT_DIR/builder/context.sh"
source "$SCRIPT_DIR/builder/gpu.sh"
source "$SCRIPT_DIR/builder/concurrency.sh"
source "$SCRIPT_DIR/builder/network.sh"

# Introspection
source "$SCRIPT_DIR/introspect/evaluate.sh"

show_snapshot "CUSTOM"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
