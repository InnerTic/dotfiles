#!/usr/bin/env sh
# Module: container environment
# Detects LXC/Docker/Podman, installs shells, sets defaults.
# Only activates inside a container — no-op on bare metal.

header "Container environment"

# --- container detection ---
is_container=0
if [ -f /.dockerenv ] || [ -f /run/.dockerenv ] || [ -f /run/.containerenv ]; then
  is_container=1; ctype="docker/podman"
elif [ -f /proc/1/environ ] && grep -q 'container=lxc' /proc/1/environ 2>/dev/null; then
  is_container=1; ctype="lxc"
elif [ -f /proc/1/cgroup ] && grep -qiE 'lxc|docker|containerd|kubepods' /proc/1/cgroup 2>/dev/null; then
  is_container=1; ctype="cgroup-detected"
elif [ -S /dev/lxd/sock ] 2>/dev/null; then
  is_container=1; ctype="lxd"
fi

if [ "$is_container" -eq 0 ]; then
  skip "not a container"
  return 0
fi

info "detected: $ctype"

# --- package manager ---
if command -v apt >/dev/null 2>&1; then
  pm="apt"; pm_install="apt install -y"; pm_update="apt update"
elif command -v pacman >/dev/null 2>&1; then
  pm="pacman"; pm_install="pacman -S --noconfirm"; pm_update="pacman -Sy"
elif command -v dnf >/dev/null 2>&1; then
  pm="dnf"; pm_install="dnf install -y"; pm_update="dnf makecache"
elif command -v apk >/dev/null 2>&1; then
  pm="apk"; pm_install="apk add"; pm_update="apk update"
else
  pm=""; pm_install=""; pm_update=""
fi

# --- ensure home ---
mkdir -p "$HOME"

# --- install shells ---
info "installing shells"
sudo $pm_update 2>/dev/null || true
for sh in zsh fish; do
  if ! command -v "$sh" >/dev/null 2>&1; then
    if [ -n "$pm_install" ]; then
      sudo $pm_install "$sh" 2>/dev/null || true
    fi
  fi
done

# --- set default shell ---
if command -v zsh >/dev/null 2>&1; then
  current_shell=$(basename "$(grep "^$(whoami):" /etc/passwd 2>/dev/null | cut -d: -f7)" 2>/dev/null || echo "")
  if [ "$current_shell" != "zsh" ]; then
    if command -v chsh >/dev/null 2>&1; then
      sudo chsh -s "$(command -v zsh)" "$(whoami)" 2>/dev/null && ok "default shell: zsh"
    else
      # direct /etc/passwd edit (LXC without chsh)
      sudo sed -i "s|^\($(whoami):.*:\)[^:]*$|\1$(command -v zsh)|" /etc/passwd 2>/dev/null && ok "default shell: zsh (passwd)"
    fi
  else
    ok "default shell: zsh (already set)"
  fi
fi
