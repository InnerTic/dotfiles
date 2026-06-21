#!/usr/bin/env sh
# Module: tmux
header "Tmux"
if [ -f "$DOTFILES/tmux/.tmux.conf" ]; then
  ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
  ok "tmux"
fi
