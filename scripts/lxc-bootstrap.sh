#!/usr/bin/env bash
#
# lxc-bootstrap.sh — Ken Base Environment for Proxmox LXCs
#
# Usage:  curl -fsSL https://raw.githubusercontent.com/InnerTic/dotfiles/main/scripts/lxc-bootstrap.sh | bash
# Or:     bash <(curl -fsSL ...)
#
# What it installs:
#   - lsd (modern ls), Meslo Nerd Fonts, fish shell, Tide prompt
#   - bat (cat replacement), fd-find, ripgrep, tree, btop, git, curl, nano
#
# Designed for Debian-based LXC containers. Run as root.
# ───────────────────────────────────────────────────────────────

set -euo pipefail

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
    wget

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

# ── 3. Fish shell setup ─────────────────────────────────────────

echo ">>> Configuring fish as default shell..."

FISH_PATH=$(which fish)

# Add fish to /etc/shells if missing
if ! grep -qx "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" >> /etc/shells
fi

# Change root shell to fish
if [ "$SHELL" != "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH" root
    echo ">>> Root shell changed to fish. Re-login or run 'fish' to activate."
fi

# ── 4. Fisher + Tide prompt ─────────────────────────────────────

echo ">>> Installing Fisher plugin manager..."
fish -c "
    curl -sL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
" 2>/dev/null

echo ">>> Installing Tide prompt..."
fish -c "
    fisher install IlanCosman/tide@v6
" 2>/dev/null

echo ">>> Tide installed. Run 'tide configure' interactively to customize."
echo "    Typical: Lean → 2 lines → Rounded → 16 colors → Many → Compact → Contextual → Yes"

# ── 5. Shell aliases ────────────────────────────────────────────

mkdir -p /etc/fish/conf.d

cat > /etc/fish/conf.d/ken-aliases.fish <<'EOF'
# Ken Base Environment aliases
alias cat="batcat"
alias find="fdfind"
alias ll="lsd -lah"
alias lt="lsd --tree"
EOF

# ── 6. Verification ─────────────────────────────────────────────

echo ""
echo "===== Ken Base Environment installed ====="
echo ""
echo "  Tools:"
echo "    lsd  ........... $(lsd --version 2>&1 | head -1)"
echo "    bat  ........... $(batcat --version 2>&1 | head -1)"
echo "    fd  ............ $(fdfind --version 2>&1 | head -1)"
echo "    rg  ............ $(rg --version 2>&1 | head -1)"
echo "    btop ........... $(btop --version 2>&1 | head -1)"
echo "    fish .......... $(fish --version 2>&1)"
echo "    tide .......... fisher list 2>/dev/null | grep tide || echo '(run tide configure)'"
echo ""
echo "  Fonts: $(fc-list | grep -ci meslo) Meslo NF face(s) installed"
echo ""
echo "  Next steps:"
echo "    1. Type 'fish' or re-login"
echo "    2. Run 'tide configure' to pick your prompt style"
echo "    3. Install any LXC-specific packages you need"
echo ""
