#!/usr/bin/env sh
# bootstrap.sh — thin wrapper → scripts/bootstrap/bootstrap.sh
set -e
exec "$(cd "$(dirname "$0")" && pwd)/scripts/bootstrap/bootstrap.sh" "$@"
