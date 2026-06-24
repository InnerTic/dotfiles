#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG (edit these)
# =========================

VMID="${1:-300}"
HOSTNAME="${2:-quartz-test}"
TEMPLATE="local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

STORAGE="local-lvm"
DISK_SIZE="8G"

CORES=2
MEMORY=2048
SWAP=512

BRIDGE="vmbr0"
USER_NAME="ken"

# IMPORTANT: replace with your actual public key file
PUBKEY_FILE="${PUBKEY_FILE:-$HOME/.ssh/id_rsa.pub}"

# =========================
# HELPERS
# =========================

log() { echo "[+] $*"; }

# =========================
# CREATE CONTAINER
# =========================

log "Creating LXC $VMID ($HOSTNAME)..."

pct create "$VMID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores "$CORES" \
  --memory "$MEMORY" \
  --swap "$SWAP" \
  --rootfs "$STORAGE:$DISK_SIZE" \
  --net0 "name=eth0,bridge=$BRIDGE,ip=dhcp" \
  --unprivileged 1 \
  --features nesting=1

# =========================
# START CONTAINER
# =========================

log "Starting container..."
pct start "$VMID"

sleep 3

# =========================
# BASE PACKAGES
# =========================

log "Installing base packages..."
pct exec "$VMID" -- apt update
pct exec "$VMID" -- apt install -y \
  sudo curl wget git vim nano htop openssh-server ca-certificates

# =========================
# USER SETUP
# =========================

log "Creating user $USER_NAME..."
pct exec "$VMID" -- id "$USER_NAME" &>/dev/null || \
  pct exec "$VMID" -- useradd -m -s /bin/bash "$USER_NAME"

pct exec "$VMID" -- usermod -aG sudo "$USER_NAME"

# =========================
# SSH ENABLE
# =========================

log "Enabling SSH..."
pct exec "$VMID" -- systemctl enable ssh
pct exec "$VMID" -- systemctl start ssh

# =========================
# SSH KEY SETUP
# =========================

log "Installing SSH key..."

if [[ ! -f "$PUBKEY_FILE" ]]; then
  echo "ERROR: Public key not found at $PUBKEY_FILE"
  exit 1
fi

pct exec "$VMID" -- mkdir -p /home/"$USER_NAME"/.ssh

# append key safely
cat "$PUBKEY_FILE" | pct exec "$VMID" -- tee /home/"$USER_NAME"/.ssh/authorized_keys >/dev/null

pct exec "$VMID" -- chown -R "$USER_NAME:$USER_NAME" /home/"$USER_NAME"/.ssh
pct exec "$VMID" -- chmod 700 /home/"$USER_NAME"/.ssh
pct exec "$VMID" -- chmod 600 /home/"$USER_NAME"/.ssh/authorized_keys

# =========================
# DIRECTORY LAYOUT
# =========================

log "Creating /srv layout..."

pct exec "$VMID" -- mkdir -p \
  /srv/data \
  /srv/apps \
  /srv/backups \
  /srv/shared

pct exec "$VMID" -- chown -R "$USER_NAME:$USER_NAME" /srv/data
pct exec "$VMID" -- chown -R "$USER_NAME:$USER_NAME" /srv/apps

pct exec "$VMID" -- chown root:root /srv/shared
pct exec "$VMID" -- chmod 755 /srv/shared

# optional group workspace
pct exec "$VMID" -- groupadd -f admins
pct exec "$VMID" -- usermod -aG admins "$USER_NAME"
pct exec "$VMID" -- mkdir -p /srv/workspace
pct exec "$VMID" -- chown root:admins /srv/workspace
pct exec "$VMID" -- chmod 2775 /srv/workspace

# =========================
# SNAPSHOT BASELINE
# =========================

log "Creating baseline snapshot..."
pct snapshot "$VMID" baseline

# =========================
# FINAL OUTPUT
# =========================

log "Done."
echo ""
echo "Container: $VMID ($HOSTNAME)"
echo "User: $USER_NAME"
echo "Bridge: $BRIDGE"
echo "Snapshot: baseline"
echo ""
echo "Next:"
echo "  pct enter $VMID"
echo "  ssh $USER_NAME@<ip>"
