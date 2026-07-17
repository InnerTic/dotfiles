#!/usr/bin/env bash
# bootstrap-watchtower-lxc.sh — Creates AI Watchtower LXC on Proxmox (host level)
# Build from gold/base template. Do NOT cannibalize the Quartz container.
set -euo pipefail

START_CTID="${1:-302}"
CTID="$START_CTID"

while pct status "$CTID" &>/dev/null; do
  echo "[!] CT $CTID already exists, trying $(( CTID + 1 ))"
  CTID=$(( CTID + 1 ))
done

HOSTNAME="ai-watchtower"
TEMPLATE="local/ubuntu-24.04-standard_24.04-1_amd64.tar.zst"
BRIDGE="vmbr0"
STORAGE="local-lvm"
DISK="30"           # 20-40 GB, 30 is the sweet spot
MEMORY="8192"       # 8 GB for local analysis headroom
SWAP="1024"
CORES="4"
IP="dhcp"

echo "[+] Creating LXC $CTID ($HOSTNAME)"

pct create "$CTID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores "$CORES" \
  --memory "$MEMORY" \
  --swap "$SWAP" \
  --rootfs "${STORAGE}:${DISK}" \
  --net0 name=eth0,bridge="$BRIDGE",ip="$IP" \
  --unprivileged 1

echo "[+] Starting container"
pct start "$CTID"

echo "[+] Done — Container $CTID ($HOSTNAME)"
echo "Enter with:  pct enter $CTID"
echo "Then run:    bootstrap-watchtower-stack.sh"
