#!/usr/bin/env bash
# ============================================================
# llama-loader — ENTRY POINT
# BIOS-style inference launcher for llama.cpp.
# Routes to mode scripts only — no logic here.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

clear
echo "===================================================="
echo "  llama-loader — GPU Inference Launcher"
echo "  Stateful dual-GPU execution front panel"
echo "===================================================="
echo

# Show last used summary
LAST_MODEL=$(get_state_value "last_model")
if [ -n "$LAST_MODEL" ]; then
  LAST_CTX=$(get_state_value "last_ctx")
  echo "  Last used: $LAST_MODEL  (ctx: ${LAST_CTX:-unknown})"
else
  echo "  Last used: (none)"
fi

echo "  Factory:   ctx=8192  split=30/70  np=1  ngl=60"
echo
echo "  [1] Last used"
echo "  [2] Factory default"
echo "  [3] Presets"
echo "  [4] Custom"
echo

read -p "  Select mode [1-4]: " MODE_CHOICE

case "$MODE_CHOICE" in
  1) exec "$SCRIPT_DIR/modes/last.sh" ;;
  2) exec "$SCRIPT_DIR/modes/factory.sh" ;;
  3) exec "$SCRIPT_DIR/modes/preset-router.sh" ;;
  4) exec "$SCRIPT_DIR/modes/custom.sh" ;;
  *) echo "Invalid selection"; exit 1 ;;
esac
