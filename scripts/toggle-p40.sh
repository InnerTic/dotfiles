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

LIMINE_CONF="/boot/limine.conf"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
P40_IDS="10de:1b38"

# Params added per mode
PCIEGEN3="nvidia.NVreg_EnablePCIeGen3=1"
DPM="nvidia.NVreg_DynamicPowerManagement=0x02"
VFIO_IDS="vfio-pci.ids=$P40_IDS"
VFIO_MODULES="vfio_pci vfio vfio_iommu_type1 vfio_pci_core"

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
  local param="$1"
  # Remove any existing P40/NVIDIA params from cmdline
  sudo sed -i \
    -e 's/ vfio-pci\.ids=[^ ]*//g' \
    -e 's/ nvidia\.NVreg_DynamicPowerManagement=[^ ]*//g' \
    -e 's/ nvidia\.NVreg_EnablePCIeGen3=[^ ]*//g' \
    "$LIMINE_CONF"

  if [ -n "$param" ]; then
    # Insert params after "root=UUID=" or before "rootflags="
    sudo sed -i "s|\(root=UUID=[^ ]*\)|\1 $param|" "$LIMINE_CONF"
  fi
}

apply_mkinitcpio() {
  local modules="$1"
  if [ -n "$modules" ]; then
    sudo sed -i "s/^MODULES=([^)]*)/MODULES=($modules)/" "$MKINITCPIO_CONF"
  else
    sudo sed -i "s/^MODULES=([^)]*)/MODULES=()/" "$MKINITCPIO_CONF"
  fi
}

set_mode_default() {
  echo "Setting mode: default (NVIDIA manages both GPUs, PCIe Gen3 fix)"
  apply_limine "$PCIEGEN3"
  apply_mkinitcpio ""
  sudo mkinitcpio -P
  echo "Done. Reboot to apply."
}

set_mode_dpm() {
  echo "Setting mode: dpm (Dynamic Power Management)"
  apply_limine "$DPM $PCIEGEN3"
  apply_mkinitcpio ""
  sudo mkinitcpio -P
  echo "Done. Reboot to apply."
}

set_mode_vfio() {
  echo "Setting mode: vfio (VFIO passthrough)"
  apply_limine "$VFIO_IDS $PCIEGEN3"
  apply_mkinitcpio "$VFIO_MODULES"
  sudo mkinitcpio -P
  echo "Done. Reboot to apply."
}

case "${1:-}" in
  default)  set_mode_default ;;
  dpm)      set_mode_dpm ;;
  vfio)     set_mode_vfio ;;
  *)        show_status
            echo ""
            echo "Usage: $0 {default|dpm|vfio}"
            exit 1 ;;
esac
