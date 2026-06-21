#!/usr/bin/env sh
# Module: shell configs
# Links config files for whatever shells are on the system.
header "Shell configs"

# --- zsh ---
if command -v zsh >/dev/null 2>&1; then
  if [ -f "$DOTFILES/shell/.zshrc" ]; then
    mkdir -p "$HOME"
    ln -sf "$DOTFILES/shell/.zshrc" "$HOME/.zshrc"
    ok "zsh"
  fi
fi

# --- fish ---
if command -v fish >/dev/null 2>&1; then
  if [ -f "$DOTFILES/shell/config.fish" ]; then
    mkdir -p "$HOME/.config/fish"
    ln -sf "$DOTFILES/shell/config.fish" "$HOME/.config/fish/config.fish"
    ok "fish"
  fi
fi

# --- bash (always there) ---
if [ -f "$DOTFILES/shell/.bashrc" ] && [ ! -f "$HOME/.bashrc" ]; then
  mkdir -p "$HOME"
  ln -sf "$DOTFILES/shell/.bashrc" "$HOME/.bashrc"
  ok "bashrc"
fi
if [ -f "$DOTFILES/shell/.profile" ] && [ ! -f "$HOME/.profile" ]; then
  ln -sf "$DOTFILES/shell/.profile" "$HOME/.profile"
  ok "profile"
fi
