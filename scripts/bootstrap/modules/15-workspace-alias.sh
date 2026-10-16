#!/usr/bin/env sh
# Module: workspace path alias
# The shared workspace device is mounted at different paths per OS:
#   CachyOS   -> /media/workspace
#   Debian/MX -> /mnt/workspace
# Tooling (link-workspace.sh, live-env-setup.sh) and the persisted ~/.ssh
# symlink assume /mnt/workspace. Expose the OTHER path as a symlink so both
# paths resolve on either OS.
header "Workspace alias"

_ws_a="/media/workspace"
_ws_b="/mnt/workspace"

# Identify the real mount (the one actually holding the dotfiles repo).
if [ -d "$_ws_a/dotfiles" ] && [ ! -L "$_ws_a" ]; then
  _real="$_ws_a"; _alias="$_ws_b"
elif [ -d "$_ws_b/dotfiles" ] && [ ! -L "$_ws_b" ]; then
  _real="$_ws_b"; _alias="$_ws_a"
else
  skip "no mounted workspace under $_ws_a or $_ws_b"
  return 0
fi

# Already aliased correctly?
if [ -L "$_alias" ] && [ "$(readlink "$_alias")" = "$_real" ]; then
  ok "$_alias -> $_real (present)"
  return 0
fi

# Replace an empty placeholder directory; refuse to clobber anything else.
if [ -e "$_alias" ] && [ ! -L "$_alias" ]; then
  if [ -d "$_alias" ] && [ -z "$(ls -A "$_alias" 2>/dev/null)" ]; then
    sudo rmdir "$_alias" || { skip "could not remove $_alias"; return 0; }
  else
    skip "$_alias exists and is not empty"
    return 0
  fi
fi

if sudo ln -sfn "$_real" "$_alias"; then
  ok "$_alias -> $_real (created)"
else
  skip "could not create $_alias"
fi
