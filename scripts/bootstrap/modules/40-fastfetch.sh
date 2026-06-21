#!/usr/bin/env sh
# Module: fastfetch
header "Fastfetch"
if [ -f "$DOTFILES/shell/fastfetch.jsonc" ]; then
  mkdir -p "$HOME/.config/fastfetch"
  ln -sf "$DOTFILES/shell/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  ok "fastfetch"
fi
