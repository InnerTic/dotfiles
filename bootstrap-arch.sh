#!/usr/bin/env sh
# bootstrap-arch.sh — thin wrapper → cachyos/arch profile
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/cachyos.sh" "$@"
