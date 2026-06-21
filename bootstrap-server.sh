#!/usr/bin/env sh
# bootstrap-server.sh — thin wrapper → server profile
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/server.sh" "$@"
