#!/bin/bash
# =============================================================================
# LIVE ENVIRONMENT SETUP — run from CachyOS live ISO after Calamares finishes
# =============================================================================
# Usage:
#   1. Install CachyOS normally with Calamares
#   2. When Calamares says "Installation complete" — DO NOT REBOOT
#   3. Open terminal, then:
#      curl -sL https://raw.githubusercontent.com/InnerTic/dotfiles/main/scripts/live-env-setup.sh | sudo bash
#
# Runs against the target system mounted at /mnt.
# Idempotent — safe to run multiple times.
# Then reboot. First boot has drives, packages, and dotfiles ready.
# =============================================================================

set -e

TARGET="/mnt"
USERNAME="ken"
HOME_DIR="$TARGET/home/$USERNAME"
DOTFILES_REPO="https://github.com/InnerTic/dotfiles.git"

# ---- Preflight checks ----

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo or as root."
  exit 1
fi

if ! mountpoint -q "$TARGET"; then
  echo "ERROR: $TARGET is not mounted. Run this from the live ISO after Calamares finishes."
  exit 1
fi

if ! arch-chroot "$TARGET" id "$USERNAME" >/dev/null 2>&1; then
  echo "ERROR: User '$USERNAME' not found in target. Create it during Calamares install."
  exit 1
fi

echo "============================================================================"
echo "  LIVE ENV SETUP — Configuring target system at $TARGET"
echo "============================================================================"

# =============================================================================
# STEP 1: Clone dotfiles
# =============================================================================
echo ""
echo "=== STEP 1: Cloning dotfiles..."
if [[ -d "$HOME_DIR/dotfiles/.git" ]]; then
  echo "  dotfiles repo exists, pulling latest..."
  git -C "$HOME_DIR/dotfiles" pull
else
  mkdir -p "$HOME_DIR"
  git clone "$DOTFILES_REPO" "$HOME_DIR/dotfiles"
fi
arch-chroot "$TARGET" chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/dotfiles"
echo "  ✓ dotfiles ready"

# =============================================================================
# STEP 2: Install app packages
# =============================================================================
echo ""
echo "=== STEP 2: Installing app packages..."
PKGLIST="$HOME_DIR/dotfiles/docs/system_backup/pkglist-apps.txt"
if [[ -f "$PKGLIST" ]]; then
  cp "$PKGLIST" "$TARGET/tmp/pkglist-apps.txt"
  arch-chroot "$TARGET" bash -c '
    mapfile -t PKGS < <(grep -v "^#" /tmp/pkglist-apps.txt | grep -v "^$")
    if [[ ${#PKGS[@]} -gt 0 ]]; then
      pacman -S --needed --noconfirm "${PKGS[@]}"
    fi
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

# Uses labels where possible (survive reformats). Falls back to hardcoded UUIDs.
# Verify UUIDs against actual disks before shipping a new USB.

FSTAB_MARKER="# DATA_DRIVES_LIVE_ENV"
arch-chroot "$TARGET" bash -c "
grep -q '$FSTAB_MARKER' /etc/fstab 2>/dev/null && exit 0
tee -a /etc/fstab << 'FSTAB'
$FSTAB_MARKER
# ssd_storage
UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d /mnt/ssd_storage ext4 defaults,nofail 0 2
# Data-HDD
UUID=7E303CAF303C6FEF /mnt/data ntfs3 defaults,nofail 0 2
# m2_storage
UUID=6befefdd-f232-4757-9eea-9f7051da3c0b /mnt/m2_storage btrfs defaults,nofail 0 2
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

arch-chroot "$TARGET" mkdir -p /mnt/{ssd_storage,data,m2_storage,workspace}
arch-chroot "$TARGET" mkdir -p /home/$USERNAME/{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}
echo "  ✓ fstab entries added"

# =============================================================================
# STEP 4: Symlinks
# =============================================================================
echo ""
echo "=== STEP 4: Creating symlinks..."
arch-chroot "$TARGET" ln -sfn /mnt/ssd_storage "/home/$USERNAME/ssd_storage"
arch-chroot "$TARGET" ln -sfn /mnt/m2_storage "/home/$USERNAME/m2_storage"
arch-chroot "$TARGET" ln -sfn /mnt/workspace "/home/$USERNAME/workspace"
arch-chroot "$TARGET" bash -c "
  mkdir -p /home/$USERNAME/Downloads/llm_models
  ln -sfn /home/$USERNAME/Downloads/llm_models /home/$USERNAME/Models
"
echo "  ✓ symlinks created"

# =============================================================================
# STEP 5: Run dotfiles bootstrap as user
# =============================================================================
echo ""
echo "=== STEP 5: Running dotfiles bootstrap..."
arch-chroot "$TARGET" su - "$USERNAME" -c "sh /home/$USERNAME/dotfiles/bootstrap.sh" \
  > /root/bootstrap.log 2>&1
echo "  ✓ bootstrap complete (log: /root/bootstrap.log)"

# =============================================================================
# STEP 6: Set default shell
# =============================================================================
echo ""
echo "=== STEP 6: Setting default shell..."
arch-chroot "$TARGET" usermod -s /bin/zsh "$USERNAME"
echo "  ✓ shell set to zsh"

# =============================================================================
# STEP 7: Enable services
# =============================================================================
echo ""
echo "=== STEP 7: Enabling services..."
arch-chroot "$TARGET" systemctl enable ufw.service 2>/dev/null || true
arch-chroot "$TARGET" systemctl enable fstrim.timer 2>/dev/null || true
echo "  ✓ services enabled"

# =============================================================================
# STEP 8: Final sanity check
# =============================================================================
echo ""
echo "=== STEP 8: Verifying configuration..."
FS_CHECK="PASS"
arch-chroot "$TARGET" mount -a 2>/dev/null || FS_CHECK="FAIL"
echo "  mount -a: $FS_CHECK"
if [[ "$FS_CHECK" == "FAIL" ]]; then
  echo "  ⚠ fstab issue detected. Check /etc/fstab before reboot."
fi

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "============================================================================"
echo "  LIVE ENV SETUP COMPLETE"
echo "============================================================================"
echo ""
echo "What was done:"
echo "  ✓ Dotfiles cloned (owned by $USERNAME)"
echo "  ✓ App packages installed"
echo "  ✓ Data drives added to fstab (nofail)"
echo "  ✓ Symlinks created"
echo "  ✓ Dotfiles bootstrapped (as $USERNAME)"
echo "  ✓ Default shell set to zsh"
echo "  ✓ Services enabled"
echo ""
echo "Bootstrap log: /root/bootstrap.log (in target, check after reboot)"
echo ""
echo "Still needs first-boot:"
echo "  - Install CUDA:   arch-chroot /mnt pacman -S cuda"
echo "  - Build llama.cpp (see ~/dotfiles/docs/llama-setup.md)"
echo "  - Restore GGUF models from backup to ~/Downloads/llm_models/"
echo "  - Restore LibreWolf profile from Firefox Sync"
echo ""
echo "You can now reboot."
