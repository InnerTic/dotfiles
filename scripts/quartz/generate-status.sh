#!/usr/bin/env bash
# generate-status.sh — emits /status endpoint after Quartz build
set -e

QUARTZ_DIR="${1:-/srv/quartz}"
VAULT_DIR="${2:-/srv/vault}"
OUTPUT="$QUARTZ_DIR/public/status.json"

cd "$QUARTZ_DIR"

GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

NODE_VER=$(node -v 2>/dev/null || echo "missing")
NPM_VER=$(npm -v 2>/dev/null || echo "missing")

if [ -f "$QUARTZ_DIR/public/index.html" ]; then
  BUILD_STATUS="ok"
else
  BUILD_STATUS="missing"
fi

VAULT_HASH=$(git -C "$VAULT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
VAULT_BRANCH=$(git -C "$VAULT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
FILE_COUNT=$(find "$QUARTZ_DIR/content" -name '*.md' -type f 2>/dev/null | wc -l)

cat > "$OUTPUT" <<EOF
{
  "status": "$BUILD_STATUS",
  "build_time": "$BUILD_TIME",
  "file_count": $FILE_COUNT,
  "build": {
    "timestamp": "$BUILD_TIME",
    "files": $FILE_COUNT
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
