#!/bin/bash
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
pacman -Q | grep nvidia

echo
echo "=== libinput ==="
pacman -Q libinput

echo
echo "=== CUDA ==="
command -v nvcc && nvcc --version
