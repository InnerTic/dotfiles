#!/bin/bash
# Single purpose: install tide prompt for fish + Meslo Nerd Font
# Usage: ./install-tide-meslo.sh
#
# Run after fish is installed and bootstrap-configs.sh has linked config.fish.

set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  CONFIG
# ═══════════════════════════════════════════════════════════

TIDE_VERSION="v6"
FONT_VERSION="3.3.0"   # check https://github.com/ryanoasis/nerd-fonts/releases for latest
FONT_DIR="${FONT_DIR:-$HOME/.local/share/fonts}"
FISH_CONFIG_DIR="${FISH_CONFIG_DIR:-$HOME/.config/fish}"

# ═══════════════════════════════════════════════════════════

# ── Tide ──────────────────────────────────────────────────
install_tide() {
  if [ -f "$FISH_CONFIG_DIR/functions/tide.fish" ]; then
    echo "tide already installed, skipping."
    return
  fi

  echo "Installing tide $TIDE_VERSION..."
  local tmpdir
  tmpdir=$(mktemp -d)
  curl -sL "https://codeload.github.com/ilancosman/tide/tar.gz/$TIDE_VERSION" | tar -xzC "$tmpdir"
  cp -R "$tmpdir"/*/{completions,conf.d,functions} "$FISH_CONFIG_DIR"
  rm -rf "$tmpdir"

  echo "tide installed. Run 'tide configure' to set up your prompt."
}

# ── Meslo Nerd Font ────────────────────────────────────────
install_fonts() {
  mkdir -p "$FONT_DIR"

  local fonts_installed=0
  for f in "MesloLGS NF Regular.ttf" \
           "MesloLGS NF Bold.ttf" \
           "MesloLGS NF Italic.ttf" \
           "MesloLGS NF Bold Italic.ttf"; do
    if [ -f "$FONT_DIR/$f" ]; then
      echo "  $f already installed"
      ((fonts_installed++))
    fi
  done

  if [ "$fonts_installed" -eq 4 ]; then
    echo "All Meslo fonts already present, skipping."
    return
  fi

  echo "Downloading Meslo Nerd Font..."
  local tmpdir
  tmpdir=$(mktemp -d)
  curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v$FONT_VERSION/Meslo.zip" \
    -o "$tmpdir/Meslo.zip"
  unzip -q -o "$tmpdir/Meslo.zip" -d "$tmpdir/Meslo"
  cp "$tmpdir/Meslo/"*.ttf "$FONT_DIR/"
  rm -rf "$tmpdir"
  fc-cache -f "$FONT_DIR" 2>/dev/null || true

  echo "Meslo Nerd Font installed. Set your terminal to use 'MesloLGS NF'."
}

# ── Main ──────────────────────────────────────────────────
install_tide
echo ""
install_fonts
echo ""
echo "Done. Next steps:"
echo "  1. Set terminal font to MesloLGS NF"
echo "  2. Run: tide configure"
echo "  (Or use the interactive prompt.)"
