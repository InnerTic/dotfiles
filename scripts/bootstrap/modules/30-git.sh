#!/usr/bin/env sh
# Module: git config
header "Git"
if [ -f "$DOTFILES/git/.gitconfig" ]; then
  ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
  ok "gitconfig"
fi
