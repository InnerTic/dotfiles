# symlink-workspace.sh

```bash
#!/bin/bash
# Extracted from: live-env-setup.sh (Step 4) + REBUILD_SCRIPT.sh (Step 3)
# Single purpose: create storage symlinks in home directory
# Usage: ./symlink-workspace.sh

set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  CONFIG — change these to match your drive layout
# ═══════════════════════════════════════════════════════════

SSD="/mnt/ssd_storage"   # <-- swap: your bulk data drive
M2="/mnt/m2_storage"     # <-- swap: your secondary data drive
WS="/mnt/workspace"      # <-- swap: your workspace drive
USER="ken"                # <-- swap: your username

# ═══════════════════════════════════════════════════════════

ln -sfn "$SSD" ~/ssd_storage
ln -sfn "$M2"  ~/m2_storage
ln -sfn "$WS"  ~/workspace
sudo ln -sfn "$WS" /workspace

mkdir -p ~/Downloads/llm_models
ln -sfn ~/Downloads/llm_models ~/Models

echo "Symlinks created:"
echo "  ~/ssd_storage  → $SSD"
echo "  ~/m2_storage   → $M2"
echo "  ~/workspace    → $WS"
echo "  /workspace     → $WS"
echo "  ~/Models       → ~/Downloads/llm_models"
```
