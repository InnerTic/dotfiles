# migrate-home-data.sh

```bash
#!/bin/bash
# One-time data migration — copy ~/*.backup dirs to a data drive.
# Run this BEFORE setting up bind mounts with fstab-bind-mounts.sh.
# Usage: sudo ./migrate-home-data.sh

set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  CONFIG — change these to match your drive layout
# ═══════════════════════════════════════════════════════════

TARGET="/mnt/ssd_storage"   # <-- swap this: external drive, data-hdd, etc.
USER="ken"                   # <-- swap this: your username

# ═══════════════════════════════════════════════════════════

if [ ! -d "$TARGET" ]; then
  echo "ERROR: $TARGET not found or not mounted."
  echo "Edit the TARGET variable at the top of this script."
  exit 1
fi

DIRS=(Documents Downloads Pictures Videos Desktop Music go MEGA)

for dir in "${DIRS[@]}"; do
  src="$HOME/$dir.backup"
  dst="$TARGET/$USER/$dir"

  if [ -d "$src" ]; then
    echo "→ $dir"
    mkdir -p "$dst"
    rsync -av --progress "$src/" "$dst/"
  else
    echo "  $dir — no $HOME/$dir.backup found, skipping"
  fi
done

echo ""
echo "Done. Verify data at $TARGET/$USER/"
echo "Then run fstab-bind-mounts.sh to set up bind mounts."
```
