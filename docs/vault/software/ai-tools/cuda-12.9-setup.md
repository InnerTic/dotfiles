---
tags: [setup, cuda, nvidia, debian]
aliases: [cuda-setup, cuda-12.9, install-cuda]
updated: 2026-06-17
---

# CUDA 12.9 — Debian Manual Install

CUDA 12.9 is not in the Debian repos. Install via NVIDIA's runfile.

## Step 1: Install Build Dependencies

```bash
sudo apt update
sudo apt install -y build-essential cmake git linux-headers-$(uname -r)
```

## Step 2: Download CUDA 12.9 Runfile

```bash
curl -L "https://developer.download.nvidia.com/compute/cuda/12.9.0/local_installers/cuda_12.9.0_580.54.14_linux.run" \
  -o /tmp/cuda_12.9.0_linux.run
chmod +x /tmp/cuda_12.9.0_linux.run
```

## Step 3: Install Toolkit Only (no driver)

```bash
sudo /tmp/cuda_12.9.0_linux.run \
  --toolkit \
  --toolkitpath=/opt/cuda-12.9 \
  --silent \
  --override
```

Installs to `/opt/cuda-12.9/`. The driver is managed by Debian's `nvidia-driver` package separately — do **not** install the driver from the runfile.

## Step 4: Set Up Environment

```bash
# Add to ~/.zshrc or ~/.profile:
export PATH=/opt/cuda-12.9/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda-12.9/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/opt/cuda-12.9
```

Source it:

```bash
source ~/.zshrc
```

## Step 5: Verify nvcc

```bash
nvcc --version
# Should show: release 12.9
```

## Step 6: Prevent ldconfig Conflicts

If you ever had another CUDA install, check for stale ld config:

```bash
ls /etc/ld.so.conf.d/ | grep cuda
# Remove any old CUDA entries:
sudo rm -f /etc/ld.so.conf.d/cuda-12-4.conf
sudo ldconfig
```

The wrong CUDA libs in ldconfig cause llama.cpp to load mismatched `libcudart.so` at runtime and silently fall back to CPU.

## Step 7: Verify GPU Visibility

```bash
nvidia-smi
# Should show both: RTX 3060 + Tesla P40
```

## Why This Works for Both GPUs

CUDA 12.9's nvcc compiles for sm_61 (Tesla P40/Pascal) and sm_86 (RTX 3060/Ampere) without any patches or older GCC. No gcc-9 wrapper needed — the default system GCC works.

## Related

- [[software/ai-tools/llama-cpp-build]] — Build llama.cpp with this CUDA install
- [[gpu/gpu-config-notes]] — Full GPU stack reference
