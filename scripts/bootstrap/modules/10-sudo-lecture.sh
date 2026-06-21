#!/usr/bin/env sh
# Module: sudo lecture
header "Sudo lecture"
if [ -f "$DOTFILES/etc/sudo-lecture.txt" ] && [ ! -f /etc/sudo-lecture.txt ]; then
  sudo cp "$DOTFILES/etc/sudo-lecture.txt" /etc/sudo-lecture.txt
  ok "sudo lecture copied"
fi
if [ -f "$DOTFILES/etc/custom-lecture.sudoers" ] && [ ! -f /etc/sudoers.d/custom-lecture ]; then
  sudo cp "$DOTFILES/etc/custom-lecture.sudoers" /etc/sudoers.d/custom-lecture
  sudo chmod 440 /etc/sudoers.d/custom-lecture
  ok "sudo lecture sudoers installed"
fi
