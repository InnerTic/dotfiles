#!/usr/bin/env bash
# bootstrap-quartz-lxc.sh — Creates a Quartz LXC on Proxmox (host level)
set -euo pipefail

START_CTID="${1:-301}"
CTID="$START_CTID"

while pct status "$CTID" &>/dev/null; do
  echo "[!] CT $CTID already exists, trying $(( CTID + 1 ))"
  CTID=$(( CTID + 1 ))
done

HOSTNAME="quartz-base"
TEMPLATE="local/ubuntu-24.04-standard_24.04-1_amd64.tar.zst"
BRIDGE="vmbr0"
STORAGE="local-lvm"
DISK="20"
MEMORY="4096"
SWAP="512"
CORES="2"
IP="dhcp"

echo "[+] Creating LXC $CTID ($HOSTNAME)"

pct create "$CTID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores "$CORES" \
  --memory "$MEMORY" \
  --swap "$SWAP" \
  --rootfs "${STORAGE}:${DISK}" \
  --net0 name=eth0,bridge="$BRIDGE",ip="$IP" \
  --unprivileged 1 \
  --features nesting=1

echo "[+] Starting container"
pct start "$CTID"

echo "[+] Done — Container $CTID ($HOSTNAME)"
echo "Enter with:  pct enter $CTID"
