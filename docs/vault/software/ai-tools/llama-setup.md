# llama.cpp

CUDA 12.4 (Debian) / 12.9 (CachyOS) · sm_61 + sm_86 (RTX 3060 + Tesla P40)

## Debian

### Prerequisites

```bash
sudo apt update
sudo apt install -y build-essential cmake git nvidia-cuda-toolkit
```

`nvidia-cuda-toolkit` provides CUDA 12.4 from the Debian repo. nvcc lands at `/usr/bin/nvcc`.

> Driver may report CUDA 13.0 runtime but the *toolkit* is 12.4 — that's fine.
>
> Build artifacts link against glibc 2.41. They will NOT run on CachyOS (glibc 2.43). Always rebuild per-distro.

Also install the NVIDIA driver if not done:

```bash
sudo apt install -y nvidia-driver firmware-misc-nonfree
```

### Clone & Build

```bash
cd /mnt/workspace
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
rm -rf build
cmake -S . -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86"
cmake --build build -j$(nproc)
```

### Verify

```bash
./build/bin/llama-server --help 2>&1 | grep -i cuda
nvidia-smi
```

### Quick Test

```bash
./build/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
  --host 0.0.0.0 --port 8080 \
  -ngl 35 --ctx-size 131072 --no-kv-offload
```

### Upgrade

```bash
cd /mnt/workspace/llama.cpp
git pull
rm -rf build
cmake -S . -B build -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="61;86"
cmake --build build -j$(nproc)
```

## CachyOS

### Prerequisites

```bash
sudo pacman -S --needed base-devel cmake git cuda-12.9
```

CUDA 12.9 lands at `/opt/cuda/`. System GCC works fine as host compiler.

> Build artifacts link against glibc 2.43 (CachyOS). They will NOT run on Debian (glibc 2.41). Always rebuild per-distro.

### Clone & Build

```bash
cd /mnt/workspace
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
rm -rf build
cmake -S . -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCUDAToolkit_ROOT=/opt/cuda
cmake --build build -j$(nproc)
```

### Verify CUDA Offload

```bash
./build/bin/llama-server --help 2>&1 | grep -i cuda
nvidia-smi
```

### Quick Test

```bash
./build/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
  --host 0.0.0.0 --port 8080 \
  -ngl 35 --ctx-size 131072 --no-kv-offload
```

### Upgrade

```bash
cd /mnt/workspace/llama.cpp
git pull
rm -rf build
cmake -S . -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCUDAToolkit_ROOT=/opt/cuda
cmake --build build -j$(nproc)
```

## GPU Layout

| GPU | Device | CUDA | Port | Job |
|-----|--------|------|------|-----|
| RTX 3060 (sm_86, 12GB) | 0 | — | :8080 | Default, small LLMs |
| Tesla P40 (sm_61, 24GB) | 1 | `CUDA_VISIBLE_DEVICES=1` | :8081 | Big models, `--main-gpu 1` |

## P40 Considerations

The P40 (24GB, Pascal/sm_61) is good for running larger quantized LLMs via llama.cpp but has major caveats for PyTorch-based tools:

| Limitation | Impact |
|------------|--------|
| **sm_61 not in modern torch builds** | Torch 2.11+cu130 ships sm_75+. P40 needs a custom torch build or older torch |
| **No FP16 tensor cores** | FP16 runs at ~1/2 speed (emulated). FP32 is native but more VRAM |
| **No FP8 support** | Can't use SD XL/3 optimizations that rely on FP8 |

### BIOS Quirk — P40 Won't POST Without Config First

The P40 doesn't initialize its PCIe link properly at boot unless BIOS settings are configured *before* installing the card:

1. With the P40 not installed, boot into BIOS
2. Enable **Above 4G Decoding** (PCI Subsystem Settings)
3. Disable **CSM** — set to UEFI only
4. Enable **Resizable BAR** (if available)
5. Save & shutdown, install the P40, boot

If it still won't POST: reseat the P40, clear CMOS, or force PCIe Gen3 in BIOS.

### P40 Invisible — Power Cable

If `lspci` shows `Kernel driver in use: nvidia` but `nvidia-smi` doesn't show the P40:

```bash
dmesg | grep -i nvidia
# Look for: "GPU does not have the necessary power cables connected"
```

**Fix:** Both 8-pin power connectors must be plugged in from the PSU side.

### P40 Invisible — PCIe Gen3 Fix

```bash
# Add to kernel cmdline:
nvidia.NVreg_EnablePCIeGen3=1
```

Verify:

```bash
cat /proc/driver/nvidia/params | grep EnablePCIeGen3
# Should show: EnablePCIeGen3: 1
```

### Dual GPU Workload Split

| GPU | Job | Why |
|-----|-----|-----|
| RTX 3060 (12GB) | Forge/SD WebUI, small LLMs | Tensor cores, FP16 native |
| Tesla P40 (24GB) | llama.cpp big models (30B-70B Q4) | More VRAM, doesn't need FP16 |

**P40 Isolation for [[llama-server]]:**

```bash
CUDA_VISIBLE_DEVICES=1 ~/.local/bin/llama-server.sh \
  -m ~/models/<model>.gguf \
  --host 0.0.0.0 --port 8080 \
  --main-gpu 1 -ngl 64 --ctx-size 131072
```

> `--main-gpu 1` does NOT prevent model loading on GPU 0. Must use `CUDA_VISIBLE_DEVICES=1` for true P40 isolation.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `CUDA error: out of memory` | Lower `-ngl` or add `--no-kv-offload` |
| `llama-server: command not found` | Build first or check path |
| Model not appearing in OpenCode | Check model ID matches filename in config |
| Slow token generation | Verify CUDA offload is working (`nvidia-smi` shows GPU usage) |
| CPU fallback (no GPU offload) | Check `sudo ldconfig -p | grep cuda` for stale library paths |

## Related

- Launch wrapper: `scripts/llama-server.sh`
- Interactive model picker: `scripts/llama-loader`
- Alias: `llm`
