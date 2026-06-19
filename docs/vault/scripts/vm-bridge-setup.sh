#!/usr/bin/env bash
set -euo pipefail

IFACE="enp6s0"
BRIDGE="br0"
SLAVE="br0-${IFACE}"

echo "[1/6] Cleaning old bridge configs..."

nmcli connection delete "$BRIDGE" 2>/dev/null || true
nmcli connection delete "$SLAVE" 2>/dev/null || true

echo "[2/6] Creating bridge $BRIDGE..."

nmcli connection add \
  type bridge \
  ifname "$BRIDGE" \
  con-name "$BRIDGE"

echo "[3/6] Setting DHCP on bridge..."

nmcli connection modify "$BRIDGE" \
  ipv4.method auto \
  ipv6.method auto

echo "[4/6] Attaching physical NIC $IFACE..."

nmcli connection add \
  type bridge-slave \
  ifname "$IFACE" \
  master "$BRIDGE" \
  con-name "$SLAVE"

echo "[5/6] Bringing connections down (safe reset)..."

nmcli connection down "$BRIDGE" 2>/dev/null || true
nmcli connection up "$BRIDGE"

nmcli connection up "$SLAVE"

echo "[6/6] Verifying state..."

ip a show "$BRIDGE" || true
nmcli connection show --active

echo "DONE: Bridge is active and DHCP should come from router."
