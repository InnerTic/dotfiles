#!/usr/bin/env bash
# update-quartz.sh — pull vault, rebuild site, emit /status
set -e

VAULT_DIR="${1:-/srv/vault}"
QUARTZ_DIR="${2:-/srv/quartz}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$VAULT_DIR"
git pull

rsync -av --delete "$VAULT_DIR/docs/" "$QUARTZ_DIR/content/"

cd "$QUARTZ_DIR"
npx quartz build

"$SCRIPT_DIR/quartz/generate-status.sh" "$QUARTZ_DIR" "$VAULT_DIR"
