#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG
# =========================

VMID="9000"
HOSTNAME="debian12-gold"
TEMPLATE="local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

STORAGE="local-lvm"
BRIDGE="vmbr0"

USER_NAME="ken"

echo "[+] Creating base container $VMID (gold build environment)"

# =========================
# CREATE BASE CONTAINER
# =========================

pct create "$VMID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores 2 \
  --memory 2048 \
  --swap 512 \
  --rootfs "$STORAGE:8G" \
  --net0 name=eth0,bridge="$BRIDGE",ip=dhcp \
  --unprivileged 1 \
  --features nesting=1

pct start "$VMID"
sleep 5

# =========================
# BASE SYSTEM PACKAGES
# =========================

echo "[+] Installing base packages..."

pct exec "$VMID" -- apt update
pct exec "$VMID" -- apt install -y \
  sudo curl wget git vim nano htop \
  openssh-server ca-certificates

# =========================
# USER SETUP
# =========================

echo "[+] Creating user $USER_NAME..."

pct exec "$VMID" -- id "$USER_NAME" &>/dev/null || \
  pct exec "$VMID" -- useradd -m -s /bin/bash "$USER_NAME"

pct exec "$VMID" -- usermod -aG sudo "$USER_NAME"

# =========================
# SSH ENABLE
# =========================

pct exec "$VMID" -- systemctl enable ssh

# =========================
# CLEAN STATE HARDENING
# =========================

echo "[+] Cleaning temporary state..."

pct exec "$VMID" -- apt clean
pct exec "$VMID" -- rm -rf /tmp/*

# =========================
# STOP CONTAINER FOR TEMPLATE CONVERSION
# =========================

pct stop "$VMID"

echo "[+] Converting to template..."

pct template "$VMID"

echo "[✓] GOLD TEMPLATE CREATED: VMID $VMID"
