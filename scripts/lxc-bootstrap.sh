#!/usr/bin/env bash
#
# lxc-bootstrap.sh — Ken Base Environment for Proxmox LXCs
#
# A thin orchestrator that delegates to modular components.
# Each component is independently idempotent and callable standalone.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/InnerTic/dotfiles/deb/scripts/lxc-bootstrap.sh)
#
# Options:
#   --minimal    Core tools only (no shell enhancements)
#   --fish       Core + fish + Tide + aliases (default)
#   --zsh        Core + zsh + OMZ + Powerlevel10k + aliases
#   --full       Everything (core + fonts + fish + zsh + aliases)
#
#   --shell <s>  Set default shell (fish|zsh, default: fish)
#
# Components (scripts/lxc/):
#   core.sh      System packages: bat, btop, fd-find, ripgrep, git, lsd, etc.
#   fonts.sh     Meslo Nerd Font (system-wide)
#   fish.sh      fish + Fisher plugin manager + Tide prompt
#   zsh.sh       zsh + Oh My Zsh + Powerlevel10k + autosuggestions
#   aliases.sh   Common aliases for both shells
#
# Designed for Debian-based LXC containers. Run as root.
# ───────────────────────────────────────────────────────────────

set -euo pipefail

# Detect script directory — handles both direct execution and pipe (curl | bash)
BASE_URL="https://raw.githubusercontent.com/InnerTic/dotfiles/deb/scripts/lxc"
if [ -f "${BASH_SOURCE[0]%/*}/lxc/core.sh" ] 2>/dev/null; then
    SCRIPT_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
    LXC_DIR="$SCRIPT_DIR/lxc"
else
    echo ">>> (pipe mode: fetching components from GitHub raw)"
    LXC_DIR="$BASE_URL"
fi

# ── Defaults ──────────────────────────────────────────────────────

MODE="fish"   # minimal | fish | zsh | full
DEFAULT_SHELL="fish"
TARGET_USER="root"

# ── Parse options ─────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimal) MODE="minimal"; shift ;;
        --fish)    MODE="fish"; DEFAULT_SHELL="fish"; shift ;;
        --zsh)     MODE="zsh"; DEFAULT_SHELL="zsh"; shift ;;
        --full)    MODE="full"; shift ;;
        --shell)   DEFAULT_SHELL="$2"; shift 2 ;;
        --user)    TARGET_USER="$2"; shift 2 ;;
        *) echo "Usage: lxc-bootstrap.sh [--minimal|--fish|--zsh|--full] [--shell fish|zsh]"; exit 1 ;;
    esac
done

# ── Execution ─────────────────────────────────────────────────────

echo "=== Ken Base Environment ==="
echo "  Mode:   $MODE"
echo "  Shell:  $DEFAULT_SHELL"
echo "  User:   $TARGET_USER"
echo ""

run_component() {
    local name="$1"
    shift
    if [[ "$LXC_DIR" == http* ]]; then
        bash <(curl -fsSL "$LXC_DIR/$name.sh") "$@"
    else
        bash "$LXC_DIR/$name.sh" "$@"
    fi
}

# core.sh is always needed
run_component core

# fonts.sh — always for full, only for fish/zsh otherwise (Tide/P10K need Meslo)
if [ "$MODE" = "full" ] || [ "$MODE" = "fish" ] || [ "$MODE" = "zsh" ]; then
    run_component fonts
fi

# fish.sh — fish mode and full mode
if [ "$MODE" = "full" ] || [ "$MODE" = "fish" ]; then
    run_component fish
fi

# zsh.sh — zsh mode and full mode
if [ "$MODE" = "full" ] || [ "$MODE" = "zsh" ]; then
    run_component zsh "$TARGET_USER"
fi

# aliases.sh — always (even minimal gets bat/fd aliases)
run_component aliases "$TARGET_USER"

# ── Set default shell ─────────────────────────────────────────────

SHELL_PATH=$(which "$DEFAULT_SHELL" 2>/dev/null || true)
if [ -n "$SHELL_PATH" ]; then
    CURRENT_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7)
    if ! grep -qx "$SHELL_PATH" /etc/shells 2>/dev/null; then
        echo "$SHELL_PATH" >> /etc/shells
    fi
    if [ "$CURRENT_SHELL" != "$SHELL_PATH" ]; then
        chsh -s "$SHELL_PATH" "$TARGET_USER"
        echo ">>> Default shell for $TARGET_USER changed to $DEFAULT_SHELL"
    fi
fi

# ── Verification ──────────────────────────────────────────────────

echo ""
echo "===== Ken Base Environment installed ====="
echo ""
echo "  Mode:   $MODE"
echo "  Shell:  $DEFAULT_SHELL ($SHELL_PATH)"
echo "  User:   $TARGET_USER"
echo ""
echo "  Tools:"
for tool in lsd batcat fdfind rg btop fish zsh; do
    ver=$($tool --version 2>&1 | head -1) && echo "    $tool .......... $ver" || echo "    $tool .......... (not found)"
done
echo "  Fonts: $(fc-list | grep -ci meslo 2>/dev/null || echo 0) Meslo NF face(s)"
echo ""
echo "  Next:"
echo "    fish:  run 'tide configure' for prompt"
echo "    zsh:   p10k wizard starts on first launch, or run 'p10k configure'"
echo ""
