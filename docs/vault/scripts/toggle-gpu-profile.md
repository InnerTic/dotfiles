# toggle-gpu-profile.sh

```bash
#!/bin/bash
# Quick toggle between Steam and AI GPU modes.
# Detects current mode from kernel cmdline and switches to the opposite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOGGLE="$SCRIPT_DIR/toggle-p40.sh"

if grep -q "vfio" /proc/cmdline; then
  echo "Currently in AI mode (VFIO). Switching to Steam (DPM)..."
  exec sudo "$TOGGLE" dpm
else
  echo "Currently in Steam mode. Switching to AI (VFIO)..."
  exec sudo "$TOGGLE" vfio
fi
```
