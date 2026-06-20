#!/usr/bin/env bash
#
# aliases.sh — Ken Base Environment shell aliases
#
# Installs aliases for both fish and zsh (idempotently).
# ───────────────────────────────────────────────

set -euo pipefail

TARGET_USER="${1:-root}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
ZSHRC="$TARGET_HOME/.zshrc"

# Fish — overwrite is safe, single source of truth
echo ">>> [aliases] Installing fish aliases..."
mkdir -p /etc/fish/conf.d
cat > /etc/fish/conf.d/ken-aliases.fish <<'EOF'
# Ken Base Environment aliases
alias cat="batcat"
alias find="fdfind"
alias ll="lsd -lah"
alias lt="lsd --tree"
EOF

# Zsh — append only if missing
if [ -f "$ZSHRC" ]; then
    echo ">>> [aliases] Installing zsh aliases..."
    for alias_line in \
        'alias cat=batcat' \
        'alias find=fdfind' \
        "alias ll='lsd -lah'" \
        "alias lt='lsd --tree'"; do
        if ! grep -qF "$alias_line" "$ZSHRC" 2>/dev/null; then
            echo "$alias_line" >> "$ZSHRC"
        fi
    done
fi
