#!/bin/bash
# Toggle Tesla P40 GPU configuration:
#   default  — NVIDIA driver manages both GPUs (PCIe Gen3 fix only)
#   dpm      — NVIDIA driver + DynamicPowerManagement to prevent hangs
#   vfio     — Isolate P40 via vfio-pci for VM passthrough
#
# Usage:
#   ./toggle-p40.sh              # show current state
#   ./toggle-p40.sh default      # NVIDIA manages both
#   ./toggle-p40.sh dpm          # Dynamic Power Management
#   ./toggle-p40.sh vfio         # VFIO passthrough

set -euo pipefail

LIMINE_CONF="/etc/default/limine"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
P40_IDS="10de:1b38"

ROOT_UUID="$(findmnt -n -o UUID /)"
BASE_CMDLINE="quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=${ROOT_UUID}"

PCIEGEN3="nvidia.NVreg_EnablePCIeGen3=1"
DPM="nvidia.NVreg_DynamicPowerManagement=0x02"
VFIO_IDS="vfio-pci.ids=$P40_IDS"
VFIO_MODULES="vfio_pci vfio vfio_iommu_type1 vfio_pci_core"

log()  { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }
die()  { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

cleanup_backups() {
  local dir="$1"
  local pattern="$2"
  local keep="${3:-3}"
  
  # Count actual files matching the pattern
  local count
  count=$(find "$dir" -maxdepth 1 -name "$pattern" | wc -l)
  
  if [ "$count" -gt "$keep" ]; then
    # Find files, sort by modification time (newest first), keep only oldest ones
    find "$dir" -maxdepth 1 -name "$pattern" -type f -print0 \
      | xargs -0 ls -t \
      | tail -n +$((keep + 1)) \
      | while read -r old; do
        sudo rm -f "$old"
        log "Pruned old backup: $old"
      done
  fi
}

validate_configs() {
  [ -f "$LIMINE_CONF" ]    || die "$LIMINE_CONF not found"
  [ -f "$MKINITCPIO_CONF" ] || die "$MKINITCPIO_CONF not found"
  [ -r "$LIMINE_CONF" ]    || die "$LIMINE_CONF not readable"
  [ -r "$MKINITCPIO_CONF" ] || die "$MKINITCPIO_CONF not readable"
}

check_sudo() {
  if ! sudo -n true 2>/dev/null; then
    die "Passwordless sudo required. Configure sudoers or run: sudo $0 $*"
  fi
}

current_mode() {
  local cmdline
  cmdline=$(cat /proc/cmdline)
  if echo "$cmdline" | grep -q "$VFIO_IDS"; then
    echo "vfio"
  elif echo "$cmdline" | grep -q "$DPM"; then
    echo "dpm"
  else
    echo "default"
  fi
}

show_status() {
  local mode
  mode=$(current_mode)
  echo "Current P40 mode: $mode"
  echo "  Kernel cmdline: $(cat /proc/cmdline)"
  echo ""
  echo "Available modes:"
  echo "  default  — NVIDIA driver manages both GPUs (PCIe Gen3 fix)"
  echo "  dpm      — Dynamic Power Management (keeps on NVIDIA, prevents hangs)"
  echo "  vfio     — VFIO passthrough (isolated from NVIDIA driver, for VMs)"
}

apply_limine() {
  set -x
  local extra_params="$1"
  local backup="${LIMINE_CONF}.bak.$(date +%s)"
  local cmdline="$BASE_CMDLINE"
  [ -n "$extra_params" ] && cmdline="$BASE_CMDLINE $extra_params"
  { set +x; } 2>/dev/null

  log "Backing up $LIMINE_CONF to $backup"
  set -x
  sudo cp "$LIMINE_CONF" "$backup"
  { set +x; } 2>/dev/null
  cleanup_backups "$(dirname "$LIMINE_CONF")" "limine.bak.*"

  log "Updating kernel cmdline..."
  set -x
  sudo awk -v new="KERNEL_CMDLINE[default]+=\"$cmdline\"" \
    '/^KERNEL_CMDLINE\[default\]/ { print new; next } 1' \
    "$LIMINE_CONF" > "${LIMINE_CONF}.tmp"
  sudo mv "${LIMINE_CONF}.tmp" "$LIMINE_CONF"
  { set +x; } 2>/dev/null
}

apply_mkinitcpio() {
  set -x
  local modules="$1"
  local backup="${MKINITCPIO_CONF}.bak.$(date +%s)"
  { set +x; } 2>/dev/null

  log "Backing up $MKINITCPIO_CONF to $backup"
  set -x
  sudo cp "$MKINITCPIO_CONF" "$backup"
  { set +x; } 2>/dev/null
  cleanup_backups "$(dirname "$MKINITCPIO_CONF")" "mkinitcpio.conf.bak.*"

  log "Updating mkinitcpio modules..."
  set -x
  if [ -n "$modules" ]; then
    sudo sed -i "s|^MODULES=([^)]*)|MODULES=($modules)|" "$MKINITCPIO_CONF"
  else
    sudo sed -i "s|^MODULES=([^)]*)|MODULES=()|" "$MKINITCPIO_CONF"
  fi
  { set +x; } 2>/dev/null
}

steam_shutdown() {
  if pgrep -x steam >/dev/null 2>&1; then
    log "Steam running, shutting down cleanly..."
    set -x
    sudo -u "$SUDO_USER" steam -shutdown 2>/dev/null || true
    { set +x; } 2>/dev/null
    for i in 1 2 3 4 5; do
      pgrep -x steam >/dev/null 2>&1 || break
      sleep 1
    done
    if pgrep -x steam >/dev/null 2>&1; then
      log "Steam didn't exit gracefully, continuing anyway..."
    fi
  fi
}

rebuild_and_reboot() {
  log "Rebuilding initramfs..."
  set -x
  if ! (set +o pipefail; yes | sudo mkinitcpio -P); then
    die "mkinitcpio failed. Restore from backup and retry."
  fi
  { set +x; } 2>/dev/null
  log "Rebooting..."
  set -x
  sudo reboot
  { set +x; } 2>/dev/null
}

set_mode_default() {
  log "Setting mode: default (NVIDIA manages both GPUs, PCIe Gen3 fix)"
  steam_shutdown
  apply_limine "$PCIEGEN3"
  apply_mkinitcpio ""
  rebuild_and_reboot
}

set_mode_dpm() {
  log "Setting mode: dpm (Dynamic Power Management)"
  steam_shutdown
  apply_limine "$DPM $PCIEGEN3"
  apply_mkinitcpio ""
  rebuild_and_reboot
}

set_mode_vfio() {
  log "Setting mode: vfio (VFIO passthrough)"
  steam_shutdown
  apply_limine "$VFIO_IDS $PCIEGEN3"
  apply_mkinitcpio "$VFIO_MODULES"
  rebuild_and_reboot
}

validate_configs
check_sudo

case "${1:-}" in
  default)  set_mode_default ;;
  dpm)      set_mode_dpm ;;
  vfio)     set_mode_vfio ;;
  *)        show_status ;;
esac
