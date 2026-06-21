#!/usr/bin/env sh
# bootstrap-container.sh — thin wrapper → container profile
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/container.sh" "$@"
