#!/usr/bin/env sh
# Module: SSH
# ~/.ssh is persisted on the workspace by link-workspace.sh (as a symlink to
# <workspace>/.ssh), so the workspace copy is the source of truth. Only seed a
# config from the repo when one is not already present — never clobber keys or
# a config living on the workspace.
header "SSH"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ -e "$HOME/.ssh/config" ]; then
  skip "ssh config already present"
elif [ -f "$DOTFILES/ssh/config" ]; then
  ln -sf "$DOTFILES/ssh/config" "$HOME/.ssh/config"
  ok "ssh config (seeded from repo)"
fi
