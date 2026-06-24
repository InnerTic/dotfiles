#!/usr/bin/env bash
# generate-status.sh — emits /status endpoint after Quartz build
set -e

QUARTZ_DIR="${1:-/srv/quartz}"
VAULT_DIR="${2:-/srv/vault}"
OUTPUT="$QUARTZ_DIR/public/status.json"

cd "$QUARTZ_DIR"

GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

NODE_VER=$(node -v)
NPM_VER=$(npm -v)

if [ -f "$QUARTZ_DIR/public/index.html" ]; then
  BUILD_STATUS="ok"
else
  BUILD_STATUS="missing"
fi

VAULT_HASH=$(git -C "$VAULT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
VAULT_BRANCH=$(git -C "$VAULT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

TIMESTAMP=$(date -Is)
N_FILES=$(find "$QUARTZ_DIR/public" -type f 2>/dev/null | wc -l)

cat > "$OUTPUT" <<EOF
{
  "status": "$BUILD_STATUS",
  "time": "$TIMESTAMP",
  "files": $N_FILES,
  "build": {
    "timestamp": "$TIMESTAMP",
    "files": $N_FILES
  },
  "git": {
    "commit": "$GIT_HASH",
    "branch": "$GIT_BRANCH"
  },
  "vault": {
    "commit": "$VAULT_HASH",
    "branch": "$VAULT_BRANCH"
  },
  "runtime": {
    "node": "$NODE_VER",
    "npm": "$NPM_VER"
  }
}
EOF
