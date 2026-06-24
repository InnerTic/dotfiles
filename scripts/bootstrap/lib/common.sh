#!/usr/bin/env sh
# Bootstrap shared library
DOTFILES="${DOTFILES:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"
export DOTFILES

header() { echo "==> $1"; }
info()  { echo "  -> $1"; }
ok()    { echo "  ✓ $1"; }
skip()  { echo "  - $1 (skipped)"; }
