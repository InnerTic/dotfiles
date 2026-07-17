#!/usr/bin/env bash
#
# zsh.sh — Zsh + Oh My Zsh + Powerlevel10k + autosuggestions + syntax highlighting
#
# Idempotent: skips OMZ install if ~/.oh-my-zsh exists.
# Plugins are appended, never clobbered.
# ───────────────────────────────────────────────

set -euo pipefail

# Resolve target user (defaults to root, override with --user flag)
TARGET_USER="${1:-root}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
ZSHRC="$TARGET_HOME/.zshrc"
ZSH_DIR="$TARGET_HOME/.oh-my-zsh"

if [ ! -x "$(which zsh 2>/dev/null)" ]; then
    echo ">>> [zsh] zsh not found — run core.sh first"
    exit 1
fi

# ── Oh My Zsh ──────────────────────────────────
if [ -d "$ZSH_DIR" ]; then
    echo ">>> [zsh] Oh My Zsh already installed"
else
    echo ">>> [zsh] Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── Powerlevel10k ──────────────────────────────
P10K_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    echo ">>> [zsh] Powerlevel10k already installed"
else
    echo ">>> [zsh] Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Set ZSH_THEME without clobbering
if grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC" 2>/dev/null; then
    echo ">>> [zsh] Powerlevel10k already enabled"
elif grep -q '^ZSH_THEME=' "$ZSHRC" 2>/dev/null; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

# ── zsh-autosuggestions ────────────────────────
AUTOSUGGEST="${ZSH_CUSTOM:-$ZSH_DIR/custom}/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGEST" ]; then
    echo ">>> [zsh] zsh-autosuggestions already installed"
else
    echo ">>> [zsh] Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGEST"
fi

# ── zsh-syntax-highlighting ────────────────────
SYNTAX="${ZSH_CUSTOM:-$ZSH_DIR/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$SYNTAX" ]; then
    echo ">>> [zsh] zsh-syntax-highlighting already installed"
else
    echo ">>> [zsh] Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX"
fi

# ── Append missing plugins ─────────────────────
DESIRED_PLUGINS="git sudo history extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting"
current_plugins=$(grep -oP '^plugins=\(\K[^)]*' "$ZSHRC" 2>/dev/null || true)

if [ -n "$current_plugins" ]; then
    missing=""
    for p in $DESIRED_PLUGINS; do
        case " $current_plugins " in
            *" $p "*) ;;
            *) missing="$missing $p" ;;
        esac
    done
    if [ -n "$missing" ]; then
        sed -i "s/^plugins=($current_plugins)/plugins=($current_plugins$missing)/" "$ZSHRC"
        echo ">>> [zsh] Appended plugins:$missing"
    else
        echo ">>> [zsh] All desired plugins already present"
    fi
else
    echo "plugins=($DESIRED_PLUGINS)" >> "$ZSHRC"
fi
