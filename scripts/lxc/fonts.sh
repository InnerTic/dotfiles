#!/usr/bin/env bash
#
# fonts.sh — Meslo Nerd Font (system-wide install)
#
# Required by: Powerlevel10k, Tide prompt icons
# Idempotent: skips if all four faces exist.
# ───────────────────────────────────────────────

set -euo pipefail

FONT_DIR="/usr/local/share/fonts/truetype/meslo"
FONT_BASE="https://github.com/IlanCosman/tide/raw/assets/fonts/mesloLGS_NF"

declare -A FONTS
FONTS[regular]="MesloLGS_NF_Regular.ttf"
FONTS[bold]="MesloLGS_NF_Bold.ttf"
FONTS[italic]="MesloLGS_NF_Italic.ttf"
FONTS[bold_italic]="MesloLGS_NF_Bold_Italic.ttf"

all_exist=true
for file in "${FONTS[@]}"; do
    if [ ! -f "$FONT_DIR/$file" ]; then
        all_exist=false
        break
    fi
done

if $all_exist; then
    echo ">>> [fonts] All Meslo faces already present, skipping"
else
    echo ">>> [fonts] Installing Meslo Nerd Font..."
    mkdir -p "$FONT_DIR"
    for file in "${FONTS[@]}"; do
        dest="$FONT_DIR/$file"
        if [ ! -f "$dest" ]; then
            wget -q "$FONT_BASE/$file" -O "$dest"
        fi
    done
    fc-cache -fv 2>/dev/null
fi

echo ">>> [fonts] $(fc-list | grep -ci meslo) Meslo NF face(s) installed"
