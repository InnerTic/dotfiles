#!/usr/bin/env sh
# Module: SSH
header "SSH"
if [ -f "$DOTFILES/ssh/config" ]; then
  mkdir -p "$HOME/.ssh"
  ln -sf "$DOTFILES/ssh/config" "$HOME/.ssh/config"
  ok "ssh config"
fi
