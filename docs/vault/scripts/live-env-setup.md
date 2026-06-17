# live-env-setup.sh

```bash
#!/bin/bash
# Debian
# =============================================================================
# LIVE ENVIRONMENT SETUP — run from Debian live ISO after installer finishes
# =============================================================================
# Usage:
#   1. Install Debian normally
#   2. When installer says reboot — DO NOT REBOOT
#   3. Open terminal, then:
#      curl -sL https://raw.githubusercontent.com/InnerTic/dotfiles/deb/scripts/live-env-setup.sh | sudo bash
#
# Runs idempotent — safe to run multiple times.
# Then reboot. First boot has drives, packages, and dotfiles ready.
# =============================================================================

set -e

TARGET="/mnt"
USERNAME="ken"
HOME_DIR="$TARGET/home/$USERNAME"
DOTFILES_REPO="https://github.com/InnerTic/dotfiles.git"
DOTFILES_BRANCH="deb"

# ---- Preflight checks ----

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo or as root."
  exit 1
fi

if ! mountpoint -q "$TARGET"; then
  echo "ERROR: $TARGET is not mounted. Run this from the live ISO after installer finishes."
  exit 1
fi

if ! chroot "$TARGET" id "$USERNAME" >/dev/null 2>&1; then
  echo "ERROR: User '$USERNAME' not found in target. Create it during Debian install."
  exit 1
fi

echo "============================================================================"
echo "  LIVE ENV SETUP (Debian) — Configuring target system at $TARGET"
echo "============================================================================"

# =============================================================================
# STEP 1: Clone dotfiles
# =============================================================================
echo ""
echo "=== STEP 1: Cloning dotfiles (deb branch)..."
if [[ -d "$HOME_DIR/dotfiles/.git" ]]; then
  echo "  dotfiles repo exists, pulling latest..."
  git -C "$HOME_DIR/dotfiles" pull
  git -C "$HOME_DIR/dotfiles" checkout "$DOTFILES_BRANCH" 2>/dev/null || true
else
  mkdir -p "$HOME_DIR"
  git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$HOME_DIR/dotfiles"
fi
chroot "$TARGET" chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/dotfiles"
echo "  ✓ dotfiles ready"

# =============================================================================
# STEP 2: Install packages
# =============================================================================
echo ""
echo "=== STEP 2: Installing packages..."
PKGLIST="$HOME_DIR/dotfiles/docs/system_backup/pkglist-apps.txt"
if [[ -f "$PKGLIST" ]]; then
  cp "$PKGLIST" "$TARGET/tmp/pkglist-apps.txt"
  chroot "$TARGET" bash -c '
    apt update
    grep -v "^#" /tmp/pkglist-apps.txt | grep -v "^$" | xargs apt install -y 2>/dev/null || true
  '
  echo "  ✓ packages installed"
else
  echo "  pkglist-apps.txt not found, skipping"
fi

# =============================================================================
# STEP 3: Add data drives to fstab
# =============================================================================
echo ""
echo "=== STEP 3: Adding data drives to /etc/fstab..."

FSTAB_MARKER="# DATA_DRIVES_LIVE_ENV"
chroot "$TARGET" bash -c "
grep -q '$FSTAB_MARKER' /etc/fstab 2>/dev/null && exit 0
tee -a /etc/fstab << 'FSTAB'
$FSTAB_MARKER
# ssd_storage
UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d /mnt/ssd_storage ext4 defaults,nofail 0 2
# Data-HDD
UUID=7E303CAF303C6FEF /mnt/data ntfs-3g defaults,nofail,uid=1000,gid=1000,umask=000 0 2
# m2_storage
UUID=e070aea8-a128-4e6d-9e3f-da38a6604dbe /mnt/m2_storage btrfs defaults,nofail 0 2
# nvme-workspace
UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301 /mnt/workspace ext4 defaults,nofail 0 2

# Bind mounts
/mnt/ssd_storage/ken/Documents /home/$USERNAME/Documents none bind,nofail 0 0
/mnt/ssd_storage/ken/Downloads /home/$USERNAME/Downloads none bind,nofail 0 0
/mnt/ssd_storage/ken/Pictures /home/$USERNAME/Pictures none bind,nofail 0 0
/mnt/ssd_storage/ken/Videos /home/$USERNAME/Videos none bind,nofail 0 0
/mnt/ssd_storage/ken/Desktop /home/$USERNAME/Desktop none bind,nofail 0 0
/mnt/ssd_storage/ken/Music /home/$USERNAME/Music none bind,nofail 0 0
/mnt/ssd_storage/ken/go /home/$USERNAME/go none bind,nofail 0 0
/mnt/ssd_storage/ken/MEGA /home/$USERNAME/MEGA none bind,nofail 0 0
FSTAB
"

chroot "$TARGET" mkdir -p /mnt/{ssd_storage,data,m2_storage,workspace}
chroot "$TARGET" mkdir -p /home/$USERNAME/{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}
echo "  ✓ fstab entries added"

# =============================================================================
# STEP 4: Symlinks
# =============================================================================
echo ""
echo "=== STEP 4: Creating symlinks..."
chroot "$TARGET" ln -sfn /mnt/ssd_storage "/home/$USERNAME/ssd_storage"
chroot "$TARGET" ln -sfn /mnt/m2_storage "/home/$USERNAME/m2_storage"
chroot "$TARGET" ln -sfn /mnt/workspace "/home/$USERNAME/workspace"
chroot "$TARGET" bash -c "
  mkdir -p /home/$USERNAME/Downloads/llm_models
  ln -sfn /home/$USERNAME/Downloads/llm_models /home/$USERNAME/Models
"
chroot "$TARGET" ln -sfn /mnt/workspace /workspace
echo "  ✓ symlinks created"

# =============================================================================
# STEP 5: Run dotfiles bootstrap as user
# =============================================================================
echo ""
echo "=== STEP 5: Running dotfiles bootstrap..."
chroot "$TARGET" su - "$USERNAME" -c "sh /home/$USERNAME/dotfiles/bootstrap.sh" \
  > /root/bootstrap.log 2>&1
echo "  ✓ bootstrap complete (log: /root/bootstrap.log)"

# =============================================================================
# STEP 6: Set default shell
# =============================================================================
echo ""
echo "=== STEP 6: Setting default shell..."
chroot "$TARGET" usermod -s /bin/zsh "$USERNAME"
echo "  ✓ shell set to zsh"

# =============================================================================
# STEP 7: Enable services
# =============================================================================
echo ""
echo "=== STEP 7: Enabling services..."
chroot "$TARGET" systemctl enable ufw.service 2>/dev/null || true
chroot "$TARGET" systemctl enable fstrim.timer 2>/dev/null || true
echo "  ✓ services enabled"

# =============================================================================
# STEP 8: Final sanity check
# =============================================================================
echo ""
echo "=== STEP 8: Verifying configuration..."
FS_CHECK="PASS"
chroot "$TARGET" mount -a 2>/dev/null || FS_CHECK="FAIL"
echo "  mount -a: $FS_CHECK"
if [[ "$FS_CHECK" == "FAIL" ]]; then
  echo "  ⚠ fstab issue detected. Check /etc/fstab before reboot."
fi

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "============================================================================"
echo "  LIVE ENV SETUP COMPLETE (Debian)"
echo "============================================================================"
echo ""
echo "What was done:"
echo "  ✓ Dotfiles cloned (deb branch, owned by $USERNAME)"
echo "  ✓ Packages installed"
echo "  ✓ Data drives added to fstab (nofail)"
echo "  ✓ Symlinks created"
echo "  ✓ Dotfiles bootstrapped (as $USERNAME)"
echo "  ✓ Default shell set to zsh"
echo "  ✓ Services enabled"
echo ""
echo "Bootstrap log: /root/bootstrap.log (in target, check after reboot)"
echo ""
echo "Still needs first-boot:"
echo "  - Configure NVIDIA driver (nvidia-detect, apt install nvidia-driver)"
echo "  - Build llama.cpp or use textgen bundled binary"
echo "  - Restore GGUF models from backup to ~/Downloads/llm_models/"
echo "  - Install CUDA toolkit if building from source: apt install nvidia-cuda-toolkit"
echo "  - Install Forge (sd-webui-forge-neo) if needed"
echo ""
echo "You can now reboot."
```
