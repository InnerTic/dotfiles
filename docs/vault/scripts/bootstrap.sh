#!/usr/bin/env sh
# bootstrap.sh — symlink configs into place
# Distro-agnostic. Works on anything with a POSIX shell.

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Custom sudo lecture — one-time, harmless
if [ -f "$DOTFILES/etc/sudo-lecture.txt" ] && [ ! -f /etc/sudo-lecture.txt ]; then
  sudo cp "$DOTFILES/etc/sudo-lecture.txt" /etc/sudo-lecture.txt
fi
if [ -f "$DOTFILES/etc/custom-lecture.sudoers" ] && [ ! -f /etc/sudoers.d/custom-lecture ]; then
  sudo cp "$DOTFILES/etc/custom-lecture.sudoers" /etc/sudoers.d/custom-lecture
  sudo chmod 440 /etc/sudoers.d/custom-lecture
fi

echo "→ Linking configs from $DOTFILES"

# Shell configs
[ -f "$DOTFILES/shell/.zshrc" ] && ln -sf "$DOTFILES/shell/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES/shell/config.fish" ] && mkdir -p "$HOME/.config/fish" && ln -sf "$DOTFILES/shell/config.fish" "$HOME/.config/fish/config.fish"

# Git
[ -f "$DOTFILES/git/.gitconfig" ] && ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# Fastfetch
[ -f "$DOTFILES/shell/fastfetch.jsonc" ] && mkdir -p "$HOME/.config/fastfetch" && ln -sf "$DOTFILES/shell/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"

# Tmux
[ -f "$DOTFILES/tmux/.tmux.conf" ] && ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# SSH
[ -f "$DOTFILES/ssh/config" ] && mkdir -p "$HOME/.ssh" && ln -sf "$DOTFILES/ssh/config" "$HOME/.ssh/config"

echo "✓ Done. Restart your shell or source the config."
