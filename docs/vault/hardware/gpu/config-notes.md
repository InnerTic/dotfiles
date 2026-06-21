# GPU Configuration — Working Combo (June 2026)

## The Combo

| Component | Version | Source |
|-----------|---------|--------|
| **Driver** | **580.159.04** | pacman (`nvidia-580xx-dkms` + `-utils`) |
| **CUDA Toolkit** | **12.9.1** | pacman (`cuda-12.9`) |
| **llama.cpp** | **b1-64b38b5** | Self-built from `/mnt/workspace/llama.cpp/` |

Both GPUs work with this stack:
- **RTX 3060** (sm_86, 12GB) — port 8080 — Floppa-12B
- **Tesla P40** (sm_61, 24GB) — port 8081 — gpt-oss-20b-hermes

## Why This Works

### Root Cause of Previous CPU Fallback

The system had **two CUDA installations**:
- `/opt/cuda/` — CUDA 12.9 (pacman-managed)
- `~/.local/cuda-12.4/` — old manual install

A stale **`/etc/ld.so.conf.d/cuda-12-4.conf`** pointed to the 12.4 libraries.
`ldconfig` listed them **before** `/opt/cuda/lib64`, so llama.cpp's `libggml-cuda.so`
loaded CUDA 12.4 `libcudart.so.12` / `libcublas.so.12` at runtime instead of 12.9.
The GGML CUDA backend failed silently → fell back to CPU.

### Fix

Removed the config and rebuilt the linker cache:

```
sudo rm /etc/ld.so.conf.d/cuda-12-4.conf
sudo ldconfig
```

Then restarted llama-server — it links against `/opt/cuda/lib64/` (12.9) and
CUDA offloading works on both GPUs.

### Note on sm_61 (Tesla P40) Support

Contrary to the old docs, **CUDA 12.9's nvcc** does compile for sm_61.
The llama.cpp build was configured with:

```
CMAKE_CUDA_ARCHITECTURES=61;86
```

using `/opt/cuda/bin/nvcc` (12.9) at build time. The Pascal P40 works fine
for inference at ~250 t/s prompt / 78 t/s generation.

## Server Layout

```
GPU 0 — RTX 3060    :8080  CUDA_VISIBLE_DEVICES=0  ngl 99
GPU 1 — Tesla P40   :8081  CUDA_VISIBLE_DEVICES=1  ngl 99
```

## Key Files

- **llama.cpp build**: `/mnt/workspace/llama.cpp/build/bin/`
- **Models**: `/home/ken/Downloads/llm_models/`
- **CUDA 12.9**: `/opt/cuda/`

## If You Rebuild llama.cpp

Ensure `cmake -DCMAKE_CUDA_ARCHITECTURES="61;86"` or pass both archs.
The system `/opt/cuda/bin/nvcc` is on PATH and works with GCC 16.

## NVIDIA Driver Architecture Support

This dual-GPU setup (RTX 3060 Ampere + Tesla P40 Pascal) constrains driver choices.
NVIDIA mainline branches drop older architectures over time, so knowing which
branch supports which arch matters for distro migration or driver upgrades.

| Driver Branch | RTX 3060 (Ampere/sm_86) | Tesla P40 (Pascal/sm_61) |
|---------------|--------------------------|---------------------------|
| **580.xx** (legacy) | ✓ | ✓ |
| **590.xx** (mainline) | ✓ | ✗ — drops Pascal |
| **595.xx** (mainline) | ✓ | ✗ — drops Pascal |

The legacy 580.xx branch is the *only* current NVIDIA driver supporting both GPUs
on the same system. Mixed Pascal+Ampere under the 580 branch is confirmed working
on this system (CachyOS, DKMS). A migration to any distro shipping mainline 590+
would break the P40 unless the distro also provides a legacy 580xx package.
