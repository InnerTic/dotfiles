#!/usr/bin/env bash
#
# fish.sh — fish shell + Fisher plugin manager + Tide prompt
#
# Idempotent: Fisher and Tide are skipped if already installed.
# ───────────────────────────────────────────────

set -euo pipefail

FISH_PATH=$(which fish 2>/dev/null || true)
if [ -z "$FISH_PATH" ]; then
    echo ">>> [fish] fish not found — run core.sh first"
    exit 1
fi

echo ">>> [fish] Registering fish in /etc/shells..."
if ! grep -qx "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" >> /etc/shells
fi

# Fisher
if fish -c "fisher --version" 2>/dev/null; then
    echo ">>> [fish] Fisher already installed"
else
    echo ">>> [fish] Installing Fisher..."
    FISHER_SCRIPT=$(curl -fsSL https://git.io/fisher 2>/dev/null || true)
    if [ -n "$FISHER_SCRIPT" ]; then
        echo "$FISHER_SCRIPT" | fish -c "source - && fisher install jorgebucaran/fisher" 2>/dev/null || true
    else
        echo "    WARNING: could not fetch Fisher"
    fi
fi

# Tide
if fish -c "fisher list | grep -q tide" 2>/dev/null; then
    echo ">>> [fish] Tide already installed"
else
    echo ">>> [fish] Installing Tide @v6..."
    fish -c "fisher install IlanCosman/tide@v6" 2>/dev/null || true
    echo ">>> [fish] Run 'tide configure' interactively to customize prompt"
fi
