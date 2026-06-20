# ============================================================
# BUILDER: Context
# Prompts for context size with recommendations.
# ============================================================
echo
echo "Context size options:"
echo "  1) Model max (recommended)"
echo "  2) Standard (32768)"
echo "  3) Long context (131072)"
echo "  4) Custom"

LAST_CTX=$(resolve_default "ctx" "65536")
read -p "Select context [1-4, default: $LAST_CTX]: " CTX_CHOICE

case "$CTX_CHOICE" in
  1) CTX_SIZE=65536 ;;
  2) CTX_SIZE=32768 ;;
  3) CTX_SIZE=131072 ;;
  4) read -p "Enter context size: " CTX_SIZE ;;
  *) CTX_SIZE=$LAST_CTX ;;
esac
