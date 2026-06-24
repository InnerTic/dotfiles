# healthcheck.sh

```bash
#!/bin/bash
# Debian — replaced pacman -Q with dpkg -l
set -euo pipefail

echo "=== Shell ==="
echo "SHELL=$SHELL"
echo "Running: $(ps -p $$ -o comm=)"

echo
echo "=== NVIDIA ==="
nvidia-smi

echo
echo "=== Session ==="
echo "$XDG_SESSION_TYPE"

echo
echo "=== NVIDIA packages ==="
dpkg -l | grep nvidia || echo "(none)"

echo
echo "=== libinput ==="
dpkg -l libinput 2>/dev/null | awk '/^ii/ {print "libinput " $3}' || echo "libinput not installed"

echo
echo "=== CUDA ==="
command -v nvcc && nvcc --version
```
