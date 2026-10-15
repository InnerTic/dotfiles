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

# Reasoning prompt
echo
reason_label="ON"
if [ "$REASONING" = "off" ]; then reason_label="OFF (recommended for Gemma 4)"; fi
echo -e "Reasoning mode: \033[33m${reason_label}\033[0m"
read -p "Toggle reasoning? [y/N]: " toggle_reasoning
if [[ "$toggle_reasoning" =~ ^[Yy]$ ]]; then
  if [ "$REASONING" = "off" ]; then
    REASONING="on"
  else
    REASONING="off"
  fi
fi

# Introspection
source "$SCRIPT_DIR/introspect/evaluate.sh"

show_snapshot "CUSTOM"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
