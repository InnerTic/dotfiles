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

migrate_legacy_state
assert_clean_state

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
  echo "  Last used:"
  echo "    $LAST_MODEL"
  echo "    ctx: ${LAST_CTX:-unknown}"
else
  echo "  Last used: (none)"
fi

echo
echo "  Default profile (factory baseline):"
echo "    context:        8192  (safe fallback, not model-aware)"
echo "    gpu split:      30/70"
echo "    np:             1"
echo "    ngl:            60"
echo
echo "  Model awareness:"
echo "    ctx limit:      unknown until load-time (some models exceed 64k)"
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
