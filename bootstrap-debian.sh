#!/usr/bin/env sh
# bootstrap-debian.sh — thin wrapper → debian profile
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/debian.sh" "$@"
