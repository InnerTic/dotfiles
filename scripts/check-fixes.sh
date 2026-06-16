#!/bin/bash
# Debian — pacman -Q replaced with dpkg -l
# Quality gate for rolling updates — blocks update when tracked bugs are pending.
# New bugs get a 21-day cooldown after their upstream fix lands before passing.
#
# Usage:
#   check-fixes.sh                  Show status of all tracked bugs
#   check-fixes.sh --gate           Silent gate: exit 0=clear, 1=block (for gating updates)
#   check-fixes.sh --gate && pacman -Syu

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/check-fixes"
mkdir -p "$STATE_DIR"
GATE=false; [ "${1:-}" = "--gate" ] && GATE=true
PENDING=false; FIXED=false; BLOCK=false

# Track when a bug transitions PENDING→FIXED so we can enforce a cooldown.
COOLDOWN_DAYS=21

check () {
    local bug=$1 state=$2 desc=$3 revert=$4
    $GATE && return  # gate mode collects status only, prints nothing

    if [ "$state" = "FIXED" ]; then
        echo "[FIXED]  $bug — $desc"
        echo "         → $revert"
    else
        echo "[PENDING] $bug — $desc"
    fi
}

cooldown_active () {
    local bug=$1
    local marker="$STATE_DIR/fixed_$(echo "$bug" | tr '#' '_')"
    if [ -f "$marker" ]; then
        local fixed_at
        fixed_at=$(cat "$marker")
        local now
        now=$(date +%s)
        local elapsed=$(( (now - fixed_at) / 86400 ))
        [ "$elapsed" -lt "$COOLDOWN_DAYS" ] && return 0 || return 1
    fi
    return 1  # no marker = not yet detected as fixed
}

mark_fixed () {
    local bug=$1
    local marker="$STATE_DIR/fixed_$(echo "$bug" | tr '#' '_')"
    [ -f "$marker" ] || date +%s > "$marker"
}

# --- KDE#519773 — kio ≥ 6.26.1 ---
kio_ver=$(dpkg -l kio 2>/dev/null | awk '/^ii/ {print $3}')
if [ "$(vercmp "$kio_ver" "6.26.1")" -ge 0 ]; then
    mark_fixed "KDE#519773"
    if cooldown_active "KDE#519773"; then
        check "KDE#519773" "PENDING" "kio $kio_ver ≥ 6.26.1 (cooling down ${COOLDOWN_DAYS}d)" ""
        PENDING=true
        BLOCK=true
    else
        check "KDE#519773" "FIXED" "kio $kio_ver ≥ 6.26.1" \
            "Revert ~/.config/kiorc → behaviourOnLaunch=open"
        FIXED=true
    fi
else
    check "KDE#519773" "PENDING" "kio $kio_ver < 6.26.1" ""
    PENDING=true
fi

# --- MIME fix — protontricks-launch.desktop ---
if grep -q 'application/vnd.microsoft.portable-executable' \
    /usr/share/applications/protontricks-launch.desktop 2>/dev/null; then
    mark_fixed "protontricks_MIME"
    if cooldown_active "protontricks_MIME"; then
        check "protontricks MIME" "PENDING" "upstream fixed (cooling down ${COOLDOWN_DAYS}d)" ""
        PENDING=true
        BLOCK=true
    else
        check "protontricks MIME" "FIXED" \
            "upstream .desktop includes missing MIME type" \
            "rm ~/.local/share/applications/protontricks-launch.desktop; revert mimeapps.list"
        FIXED=true
    fi
else
    check "protontricks MIME" "PENDING" "upstream .desktop still missing the MIME type" ""
    PENDING=true
fi

# Gate mode: silent, just exit code
if $GATE; then
    if $BLOCK; then
        echo "[GATE] Blocking update — bugs on cooldown (${COOLDOWN_DAYS}d since fix)." >&2
        exit 1
    fi
    if $PENDING; then
        echo "[GATE] Blocking update — pending bugs need upstream fixes first." >&2
        exit 1
    fi
    echo "[GATE] All clear." >&2
    exit 0
fi

# Interactive mode: show revert hints
$FIXED && echo "" && echo "See docs/temporary-hacks.md for revert instructions."
$BLOCK && echo "" && echo "Cooldown: fix landed but ${COOLDOWN_DAYS}d settling period not yet met."
