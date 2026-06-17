# toggle-p40.sh

```bash
#!/bin/bash
# Toggle Tesla P40 GPU configuration:
#   default  — NVIDIA driver manages both GPUs (PCIe Gen3 fix only)
#   dpm      — NVIDIA driver + DynamicPowerManagement to prevent hangs
#   vfio     — Isolate P40 via vfio-pci for VM passthrough
#
# Usage:
#   ./toggle-p40.sh                          # show current state
#   ./toggle-p40.sh default                  # NVIDIA manages both
#   ./toggle-p40.sh dpm                      # Dynamic Power Management
#   ./toggle-p40.sh vfio                     # VFIO passthrough
#   ./toggle-p40.sh --dry-run vfio           # preview VFIO switch
#   ./toggle-p40.sh --config /path/to.yaml   # use custom config

set -euo pipefail

# ── Defaults (overridden by config file) ───────────────────
LIMINE_CONF="/etc/default/limine"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
P40_IDS="10de:1b38"
VFIO_MODULES="vfio_pci vfio vfio_iommu_type1 vfio_pci_core"
PCIEGEN3="nvidia.NVreg_EnablePCIeGen3=1"
DPM="nvidia.NVreg_DynamicPowerManagement=0x02"

DRY_RUN=false
CONFIG_FILE=""

# ── Derived ────────────────────────────────────────────────
ROOT_UUID="$(findmnt -n -o UUID / 2>/dev/null || echo 'ROOTUUID')"
BASE_CMDLINE="quiet nowatchdog splash rw rootflags=subvol=/@ root=UUID=${ROOT_UUID}"
VFIO_IDS="vfio-pci.ids=$P40_IDS"

# ── Helpers ────────────────────────────────────────────────
log()  { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }
die()  { log "ERROR: $*"; exit 1; }
warn() { log "WARNING: $*"; }

show_usage() {
  cat <<'EOF'
Usage: toggle-p40.sh [OPTIONS] [MODE]

Modes:
  default    NVIDIA driver manages both GPUs (PCIe Gen3 fix)
  dpm        Dynamic Power Management (keeps P40 on NVIDIA)
  vfio       VFIO passthrough (isolate P40 for VMs)

Options:
  --dry-run              Preview changes without executing
  --config <path>        Path to YAML config file
  -h, --help             Show this help
EOF
}

# ── Config loader (YAML) ───────────────────────────────────
load_config() {
  local config="$1"
  [[ -f "$config" ]] || return 0

  local line key val
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"  # trim leading whitespace
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    key="${line%%:*}"
    val="${line#*: }"
    val="${val#\"}"; val="${val%\"}"
    val="${val#'}"; val="${val%'}"

    case "$key" in
      limine_conf)       [[ -n "$val" ]] && LIMINE_CONF="$val" ;;
      mkinitcpio_conf)   [[ -n "$val" ]] && MKINITCPIO_CONF="$val" ;;
      p40_ids)           [[ -n "$val" ]] && P40_IDS="$val" ;;
      vfio_modules)      [[ -n "$val" ]] && VFIO_MODULES="$val" ;;
      pciegen3_param)    [[ -n "$val" ]] && PCIEGEN3="$val" ;;
      dpm_param)         [[ -n "$val" ]] && DPM="$val" ;;
    esac
  done < "$config"

  # Re-derive with (possibly updated) values
  VFIO_IDS="vfio-pci.ids=$P40_IDS"
}

# ── Backup cleanup ─────────────────────────────────────────
cleanup_backups() {
  local dir="$1"
  local pattern="$2"
  local keep="${3:-3}"

  local count
  count=$(find "$dir" -maxdepth 1 -name "$pattern" 2>/dev/null | wc -l)

  if [[ "$count" -gt "$keep" ]]; then
    if $DRY_RUN; then
      log "DRY-RUN: Would prune $((count - keep)) of $count backups in $dir ($pattern, keeping $keep)"
      return 0
    fi
    find "$dir" -maxdepth 1 -name "$pattern" -type f -print0 \
      | xargs -0 ls -t \
      | tail -n +$((keep + 1)) \
      | while read -r old; do
        sudo rm -f "$old"
        log "Pruned old backup: $old"
      done
  fi
}

# ── Preflight checks ───────────────────────────────────────
validate_configs() {
  if $DRY_RUN; then
    [[ -f "$LIMINE_CONF" ]] || warn "$LIMINE_CONF not found (dry-run, continuing)"
    [[ -f "$MKINITCPIO_CONF" ]] || warn "$MKINITCPIO_CONF not found (dry-run, continuing)"
    return 0
  fi
  [[ -f "$LIMINE_CONF" ]]    || die "$LIMINE_CONF not found"
  [[ -f "$MKINITCPIO_CONF" ]] || die "$MKINITCPIO_CONF not found"
  [[ -r "$LIMINE_CONF" ]]    || die "$LIMINE_CONF not readable"
  [[ -r "$MKINITCPIO_CONF" ]] || die "$MKINITCPIO_CONF not readable"
}

check_sudo() {
  if $DRY_RUN; then
    log "DRY-RUN: Skipping sudo check"
    return 0
  fi
  if ! sudo -n true 2>/dev/null; then
    die "Passwordless sudo required. Configure sudoers or run: sudo $0 $*"
  fi
}

# ── Mode detection ─────────────────────────────────────────
current_mode() {
  local cmdline
  cmdline=$(cat /proc/cmdline 2>/dev/null || echo "")
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
  echo "  Kernel cmdline: $(cat /proc/cmdline 2>/dev/null || echo 'N/A')"
  echo ""
  echo "Config source: ${CONFIG_FILE:-built-in defaults}"
  echo "  LIMINE_CONF=$LIMINE_CONF"
  echo "  MKINITCPIO_CONF=$MKINITCPIO_CONF"
  echo "  P40_IDS=$P40_IDS"
  echo ""
  echo "Available modes:"
  echo "  default  — NVIDIA driver manages both GPUs (PCIe Gen3 fix)"
  echo "  dpm      — Dynamic Power Management (keeps on NVIDIA, prevents hangs)"
  echo "  vfio     — VFIO passthrough (isolated from NVIDIA driver, for VMs)"
}

# ── Apply functions ────────────────────────────────────────
apply_limine() {
  local extra_params="$1"
  local cmdline="$BASE_CMDLINE"
  [[ -n "$extra_params" ]] && cmdline="$BASE_CMDLINE $extra_params"

  if $DRY_RUN; then
    log "DRY-RUN: Would back up $LIMINE_CONF to ${LIMINE_CONF}.bak.$(date +%s)"
    log "DRY-RUN: Would set kernel cmdline to:"
    log "DRY-RUN:   $cmdline"
    log "DRY-RUN: Would prune old backups (keeping last 3)"
    return 0
  fi

  local backup="${LIMINE_CONF}.bak.$(date +%s)"
  log "Backing up $LIMINE_CONF to $backup"
  sudo cp "$LIMINE_CONF" "$backup"
  cleanup_backups "$(dirname "$LIMINE_CONF")" "limine.bak.*"

  log "Updating kernel cmdline..."
  sudo awk -v new="KERNEL_CMDLINE[default]+=\"$cmdline\"" \
    '/^KERNEL_CMDLINE\[default\]/ { print new; next } 1' \
    "$LIMINE_CONF" > "${LIMINE_CONF}.tmp"
  sudo mv "${LIMINE_CONF}.tmp" "$LIMINE_CONF"
}

apply_mkinitcpio() {
  local modules="$1"

  if $DRY_RUN; then
    log "DRY-RUN: Would back up $MKINITCPIO_CONF to ${MKINITCPIO_CONF}.bak.$(date +%s)"
    if [[ -n "$modules" ]]; then
      log "DRY-RUN: Would set MODULES=($modules)"
    else
      log "DRY-RUN: Would set MODULES=()"
    fi
    log "DRY-RUN: Would prune old backups (keeping last 3)"
    return 0
  fi

  local backup="${MKINITCPIO_CONF}.bak.$(date +%s)"
  log "Backing up $MKINITCPIO_CONF to $backup"
  sudo cp "$MKINITCPIO_CONF" "$backup"
  cleanup_backups "$(dirname "$MKINITCPIO_CONF")" "mkinitcpio.conf.bak.*"

  log "Updating mkinitcpio modules..."
  if [[ -n "$modules" ]]; then
    sudo sed -i "s|^MODULES=([^)]*)|MODULES=($modules)|" "$MKINITCPIO_CONF"
  else
    sudo sed -i "s|^MODULES=([^)]*)|MODULES=()|" "$MKINITCPIO_CONF"
  fi
}

# ── Steam shutdown ─────────────────────────────────────────
steam_shutdown() {
  if $DRY_RUN; then
    if pgrep -x steam >/dev/null 2>&1; then
      log "DRY-RUN: Steam is running (PID $(pgrep -x steam)), would shut it down"
    else
      log "DRY-RUN: Steam not running, no shutdown needed"
    fi
    return 0
  fi

  if pgrep -x steam >/dev/null 2>&1; then
    log "Steam running, shutting down cleanly..."
    sudo -u "${SUDO_USER:-$USER}" steam -shutdown 2>/dev/null || true
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
  if $DRY_RUN; then
    log "DRY-RUN: Would rebuild initramfs (mkinitcpio -P)"
    log "DRY-RUN: Would reboot the system"
    return 0
  fi

  log "Rebuilding initramfs..."
  if ! (set +o pipefail; yes | sudo mkinitcpio -P); then
    die "mkinitcpio failed. Restore from backup and retry."
  fi
  log "Rebooting..."
  sudo reboot
}

# ── Mode setters ───────────────────────────────────────────
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

# ── Main ───────────────────────────────────────────────────
mode=""
params=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)     DRY_RUN=true; shift ;;
    --config)
      if [[ -n "${2:-}" ]]; then
        CONFIG_FILE="$2"
        shift 2
      else
        die "--config requires a path"
      fi
      ;;
    -h|--help)     show_usage; exit 0 ;;
    default|dpm|vfio) mode="$1"; shift ;;
    *)             die "Unknown argument: $1 (use --help for usage)" ;;
  esac
done

# Load config (system → user → explicit)
load_config "/etc/toggle-p40.yaml"
[[ -f "$HOME/.config/toggle-p40.yaml" ]] && load_config "$HOME/.config/toggle-p40.yaml"
[[ -n "$CONFIG_FILE" ]] && load_config "$CONFIG_FILE"

validate_configs

if [[ -n "$mode" ]]; then
  check_sudo
  case "$mode" in
    default)  set_mode_default ;;
    dpm)      set_mode_dpm ;;
    vfio)     set_mode_vfio ;;
  esac
else
  show_status
fi
```
