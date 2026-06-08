#!/bin/bash
# Check if upstream fixes for tracked bugs have shipped.
# No output = nothing changed. Read temporary-hacks.md for context.
# Usage: ./check-fixes.sh

set -euo pipefail

HACKS="$(dirname "$0")/../docs/temporary-hacks.md"
FIXED=false

check () {
    local bug=$1 state=$2 desc=$3 revert=$4
    if [ "$state" = "FIXED" ]; then
        echo "[FIXED]  $bug — $desc"
        echo "         → $revert"
        FIXED=true
    else
        echo "[PENDING] $bug — $desc"
    fi
}

# --- KDE#519773 — kio ≥ 6.26.1 ---
kio_ver=$(pacman -Q kio | cut -d' ' -f2)
if [ "$(vercmp "$kio_ver" "6.26.1")" -ge 0 ]; then
    check "KDE#519773" "FIXED" "kio $kio_ver ≥ 6.26.1" \
        "Revert ~/.config/kiorc → behaviourOnLaunch=open"
else
    check "KDE#519773" "PENDING" "kio $kio_ver < 6.26.1" ""
fi

# --- MIME fix — protontricks-launch.desktop ---
if grep -q 'application/vnd.microsoft.portable-executable' \
    /usr/share/applications/protontricks-launch.desktop 2>/dev/null; then
    check "protontricks MIME" "FIXED" \
        "upstream .desktop includes application/vnd.microsoft.portable-executable" \
        "rm ~/.local/share/applications/protontricks-launch.desktop; revert mimeapps.list"
else
    check "protontricks MIME" "PENDING" \
        "upstream .desktop still missing the MIME type" ""
fi

if $FIXED; then
    echo ""
    echo "See docs/temporary-hacks.md for full revert instructions."
fi
