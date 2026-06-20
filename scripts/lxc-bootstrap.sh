#!/usr/bin/env bash
#
# lxc-bootstrap.sh — Ken Base Environment for Proxmox LXCs
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/InnerTic/dotfiles/deb/scripts/lxc-bootstrap.sh)
#
# Options:
#   --shell <fish|zsh>   Set default shell (default: fish)
#   --zsh                Short for --shell zsh
#
# What it installs:
#   - Core: lsd, Meslo Nerd Fonts, bat, fd-find, ripgrep, tree, btop, git
#   - Shell (fish): fish, Fisher plugin manager, Tide prompt
#   - Shell (zsh):   zsh, Oh My Zsh, Powerlevel10k theme, autosuggestions, syntax highlighting
#
# Designed for Debian-based LXC containers. Run as root.
# ───────────────────────────────────────────────────────────────

set -euo pipefail

# ── Parse options ─────────────────────────────────────────────────

DEFAULT_SHELL="fish"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --shell) DEFAULT_SHELL="$2"; shift 2 ;;
        --zsh)   DEFAULT_SHELL="zsh"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ── Resolve target user paths ─────────────────────────────────────

# Don't assume $HOME — always resolve from passdb
TARGET_USER="root"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TARGET_SHELL_CURRENT=$(getent passwd "$TARGET_USER" | cut -d: -f7)

echo ">>> Target: $TARGET_USER @ $TARGET_HOME (current shell: $TARGET_SHELL_CURRENT)"

# ── 1. System packages ──────────────────────────────────────────

echo ">>> Updating package list..."
apt update -qq

echo ">>> Installing base tools..."
apt install -y -qq \
    bat \
    btop \
    curl \
    fd-find \
    fish \
    git \
    htop \
    nano \
    ripgrep \
    sudo \
    tree \
    wget \
    zsh

# lsd — try repo first, fall back to GitHub .deb
if ! command -v lsd &>/dev/null; then
    echo ">>> Installing lsd..."
    if apt install -y -qq lsd 2>/dev/null; then
        echo "    from apt"
    else
        echo "    fetching latest GitHub release..."
        LSD_DEB=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
            | grep "browser_download_url.*amd64.deb" \
            | cut -d: -f2- | tr -d '" ')
        if [ -n "$LSD_DEB" ]; then
            curl -fsSL "$LSD_DEB" -o /tmp/lsd.deb
            dpkg -i /tmp/lsd.deb 2>/dev/null || apt install -f -y -qq
            rm -f /tmp/lsd.deb
        else
            echo "    WARNING: could not fetch lsd .deb from GitHub"
        fi
    fi
fi

# ── 2. Meslo Nerd Font (required for Powerlevel10k / Tide) ────────

echo ">>> Installing Meslo Nerd Font..."
mkdir -p /usr/local/share/fonts/truetype/meslo

FONT_BASE="https://github.com/IlanCosman/tide/raw/assets/fonts/mesloLGS_NF"
for pair in "regular:Regular" "bold:Bold" "italic:Italic" "bold_italic:Bold_Italic"; do
    variant="${pair%%:*}"
    suffix="${pair##*:}"
    file="MesloLGS_NF_${suffix}.ttf"
    dest="/usr/local/share/fonts/truetype/meslo/$file"
    if [ ! -f "$dest" ]; then
        wget -q "$FONT_BASE/$file" -O "$dest"
    fi
done

fc-cache -fv 2>/dev/null
echo ">>> Meslo fonts installed. Verify: fc-list | grep -i meslo"

# ── 3. Fish shell + Fisher + Tide prompt ─────────────────────────

echo ">>> Setting up fish shell..."
fish_path=$(which fish)

if ! grep -qx "$fish_path" /etc/shells; then
    echo "$fish_path" >> /etc/shells
fi

# Fisher — download, source, install with verification
echo ">>> Installing Fisher plugin manager..."
FISHER_URL="https://git.io/fisher"
FISHER_SCRIPT=$(curl -fsSL "$FISHER_URL" 2>/dev/null || true)
if [ -n "$FISHER_SCRIPT" ]; then
    echo "$FISHER_SCRIPT" | fish -c "source - && fisher install jorgebucaran/fisher" 2>/dev/null || true
else
    echo "    WARNING: could not fetch Fisher from $FISHER_URL"
fi

# Tide — pinned to v6
echo ">>> Installing Tide prompt @v6..."
fish -c "fisher install IlanCosman/tide@v6" 2>/dev/null || true

echo ">>> Tide installed. Run 'tide configure' interactively to customize."
echo "    Typical: Lean → 2 lines → Rounded → 16 colors → Many → Compact → Contextual → Yes"

# ── 4. Zsh + Oh My Zsh + Powerlevel10k ────────────────────────────

if [ "$DEFAULT_SHELL" = "zsh" ]; then
    ZDOTDIR="$TARGET_HOME"
    ZSH_DIR="$ZDOTDIR/.oh-my-zsh"
    ZSHRC="$ZDOTDIR/.zshrc"

    echo ">>> Installing Oh My Zsh..."
    if [ ! -d "$ZSH_DIR" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    echo ">>> Installing Powerlevel10k theme..."
    P10K_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}/themes/powerlevel10k"
    if [ ! -d "$P10K_DIR" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    fi

    # Set ZSH_THEME — only if not already set to powerlevel10k
    if [ -f "$ZSHRC" ]; then
        if grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC"; then
            echo "    Powerlevel10k already enabled in .zshrc"
        elif grep -q '^ZSH_THEME=' "$ZSHRC"; then
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
        fi
    fi

    echo ">>> Installing zsh-autosuggestions..."
    ZSH_AUTOSUGGEST="${ZSH_CUSTOM:-$ZSH_DIR/custom}/plugins/zsh-autosuggestions"
    if [ ! -d "$ZSH_AUTOSUGGEST" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGEST"
    fi

    echo ">>> Installing zsh-syntax-highlighting..."
    ZSH_SYNTAX="${ZSH_CUSTOM:-$ZSH_DIR/custom}/plugins/zsh-syntax-highlighting"
    if [ ! -d "$ZSH_SYNTAX" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX"
    fi

    # Append missing plugins without clobbering existing ones
    DESIRED_PLUGINS="git sudo history extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting"
    if [ -f "$ZSHRC" ]; then
        current_plugins=$(grep -oP '^plugins=\(\K[^)]*' "$ZSHRC" || true)
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
                echo "    Appended missing plugins:$missing"
            else
                echo "    All desired plugins already present"
            fi
        else
            echo "plugins=($DESIRED_PLUGINS)" >> "$ZSHRC"
        fi
    fi
fi

# ── 5. Set default shell ─────────────────────────────────────────

echo ">>> Setting $DEFAULT_SHELL as default shell..."
SHELL_PATH="$(which "$DEFAULT_SHELL")"

if ! grep -qx "$SHELL_PATH" /etc/shells; then
    echo "$SHELL_PATH" >> /etc/shells
fi

if [ "$TARGET_SHELL_CURRENT" != "$SHELL_PATH" ]; then
    chsh -s "$SHELL_PATH" "$TARGET_USER"
    echo ">>> Default shell changed to $DEFAULT_SHELL. Re-login or type '$DEFAULT_SHELL' to activate."
fi

# ── 6. Shell aliases ────────────────────────────────────────────

# Fish — overwrite is safe (single source of truth)
mkdir -p /etc/fish/conf.d
cat > /etc/fish/conf.d/ken-aliases.fish <<'EOF'
# Ken Base Environment aliases
alias cat="batcat"
alias find="fdfind"
alias ll="lsd -lah"
alias lt="lsd --tree"
EOF

# Zsh — append only if not already present
if [ "$DEFAULT_SHELL" = "zsh" ] && [ -f "$ZSHRC" ]; then
    for alias_line in \
        'alias cat=batcat' \
        'alias find=fdfind' \
        "alias ll='lsd -lah'" \
        "alias lt='lsd --tree'"; do
        if ! grep -qF "$alias_line" "$ZSHRC"; then
            echo "$alias_line" >> "$ZSHRC"
        fi
    done
fi

# ── 7. Verification ─────────────────────────────────────────────

echo ""
echo "===== Ken Base Environment installed ====="
echo ""
echo "  Target:  $TARGET_USER @ $TARGET_HOME"
echo "  Shell:   $DEFAULT_SHELL -> $SHELL_PATH"
echo ""
echo "  Tools:"
echo "    lsd  ........... $(lsd --version 2>&1 | head -1)"
echo "    bat  ........... $(batcat --version 2>&1 | head -1)"
echo "    fd  ............ $(fdfind --version 2>&1 | head -1)"
echo "    rg  ............ $(rg --version 2>&1 | head -1)"
echo "    btop ........... $(btop --version 2>&1 | head -1)"
echo "    fish .......... $(fish --version 2>&1)"
echo "    zsh ............ $(zsh --version 2>&1 | head -1)"
echo "    tide .......... $(fish -c 'fisher list | grep tide' 2>/dev/null || echo 'installed')"
echo ""
echo "  Fonts: $(fc-list | grep -ci meslo) Meslo NF face(s) installed"
echo ""
echo "  Next steps:"
echo "    1. Re-login or run '$DEFAULT_SHELL'"
echo "    2. Fish:   run 'tide configure' for prompt setup"
echo "    3. Zsh:    p10k wizard starts on first launch, or run 'p10k configure'"
echo "    4. Install any LXC-specific packages you need"
echo ""
