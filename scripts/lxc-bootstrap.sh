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

# lsd is not in Debian repos by default — grab the .deb directly
if ! command -v lsd &>/dev/null; then
    echo ">>> Installing lsd (latest release)..."
    LSD_DEB=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
        | grep "browser_download_url.*amd64.deb" \
        | cut -d: -f2- | tr -d '" ')
    curl -fsSL "$LSD_DEB" -o /tmp/lsd.deb
    dpkg -i /tmp/lsd.deb 2>/dev/null || apt install -f -y -qq
    rm -f /tmp/lsd.deb
fi

# ── 2. Meslo Nerd Font (required for Tide prompt icons) ─────────

echo ">>> Installing Meslo Nerd Font..."
mkdir -p /usr/local/share/fonts/truetype/meslo
cd /usr/local/share/fonts/truetype/meslo

FONT_BASE="https://github.com/IlanCosman/tide/raw/assets/fonts/mesloLGS_NF"
for variant in regular bold italic bold_italic; do
    case "$variant" in
        regular)     file="MesloLGS_NF_Regular.ttf";     url="$FONT_BASE/${file}" ;;
        bold)        file="MesloLGS_NF_Bold.ttf";        url="$FONT_BASE/${file}" ;;
        italic)      file="MesloLGS_NF_Italic.ttf";      url="$FONT_BASE/${file}" ;;
        bold_italic) file="MesloLGS_NF_Bold_Italic.ttf"; url="$FONT_BASE/${file}" ;;
    esac
    if [ ! -f "$file" ]; then
        wget -q "$url" -O "$file"
    fi
done

fc-cache -fv 2>/dev/null
echo ">>> Meslo fonts installed. Verify: fc-list | grep -i meslo"

# ── 3. Fish shell + Fisher + Tide prompt ─────────────────────────

echo ">>> Setting up fish shell..."
fish_path=$(which fish)

# Register fish in /etc/shells
if ! grep -qx "$fish_path" /etc/shells; then
    echo "$fish_path" >> /etc/shells
fi

# Install Fisher and Tide regardless (fish is always available for admin use)
echo ">>> Installing Fisher plugin manager..."
fish -c "
    curl -sL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
" 2>/dev/null || true

echo ">>> Installing Tide prompt..."
fish -c "
    fisher install IlanCosman/tide@v6
" 2>/dev/null || true

echo ">>> Tide installed. Run 'tide configure' interactively to customize."
echo "    Typical: Lean → 2 lines → Rounded → 16 colors → Many → Compact → Contextual → Yes"

# ── 4b. Zsh + Oh My Zsh + Powerlevel10k ───────────────────────────

if [ "$DEFAULT_SHELL" = "zsh" ]; then
    echo ">>> Installing Oh My Zsh..."
    ZSH="$HOME/.oh-my-zsh"
    if [ ! -d "$ZSH" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    echo ">>> Installing Powerlevel10k theme..."
    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$P10K_DIR" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    fi

    echo ">>> Enabling Powerlevel10k in .zshrc..."
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"

    echo ">>> Installing zsh-autosuggestions..."
    ZSH_AUTOSUGGEST="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [ ! -d "$ZSH_AUTOSUGGEST" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGEST"
    fi

    echo ">>> Installing zsh-syntax-highlighting..."
    ZSH_SYNTAX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [ ! -d "$ZSH_SYNTAX" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX"
    fi

    echo ">>> Enabling plugins in .zshrc..."
    sed -i 's/^plugins=(git)/plugins=(git sudo history extract colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
fi

# ── 5. Set default shell ─────────────────────────────────────────

echo ">>> Setting $DEFAULT_SHELL as default shell..."
SHELL_PATH="$(which "$DEFAULT_SHELL")"

if ! grep -qx "$SHELL_PATH" /etc/shells; then
    echo "$SHELL_PATH" >> /etc/shells
fi

if [ "$SHELL" != "$SHELL_PATH" ]; then
    chsh -s "$SHELL_PATH" root
    echo ">>> Default shell changed to $DEFAULT_SHELL. Re-login or type '$DEFAULT_SHELL' to activate."
fi

# ── 6. Shell aliases ────────────────────────────────────────────

mkdir -p /etc/fish/conf.d

cat > /etc/fish/conf.d/ken-aliases.fish <<'EOF'
# Ken Base Environment aliases
alias cat="batcat"
alias find="fdfind"
alias ll="lsd -lah"
alias lt="lsd --tree"
EOF

if [ "$DEFAULT_SHELL" = "zsh" ] && [ -f "$HOME/.zshrc" ]; then
    cat >> "$HOME/.zshrc" <<'EOF'

# Ken Base Environment aliases
alias cat=batcat
alias find=fdfind
alias ll='lsd -lah'
alias lt='lsd --tree'
EOF
fi

# ── 7. Verification ─────────────────────────────────────────────

echo ""
echo "===== Ken Base Environment installed ====="
echo ""
echo "  Default shell: $DEFAULT_SHELL"
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
