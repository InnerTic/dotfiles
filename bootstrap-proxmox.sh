#!/usr/bin/env sh
# bootstrap-proxmox.sh — thin wrapper → proxmox profile
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/proxmox.sh" "$@"
