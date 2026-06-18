# llama.cpp — Fresh Install to Running Server (Debian)

CUDA 12.4 (apt) · sm_61 + sm_86 (RTX 3060 + Tesla P40)

## Prerequisites

```bash
sudo apt update
sudo apt install -y build-essential cmake git nvidia-cuda-toolkit
```

`nvidia-cuda-toolkit` provides CUDA 12.4 from the Debian repo. nvcc lands at `/usr/bin/nvcc`.

> Driver may report CUDA 13.0 runtime but the *toolkit* is 12.4 — that's fine. Don't try to install CUDA 12.9 on Debian, it's not in repos and the build works with 12.4.
>
> Build artifacts link against glibc 2.41. They will NOT run on CachyOS (glibc 2.43). Always rebuild per-distro.

Also install the NVIDIA driver if not done:
```bash
sudo apt install -y nvidia-driver firmware-misc-nonfree
```

## Clone & Build

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

System nvcc (CUDA 12.4) and system GCC are on PATH — cmake finds them automatically. No special GCC or patches needed.

Build outputs in `build/bin/`:
- `llama-server` — main server (OpenAI-compatible API on :8080)
- `llama-cli` — CLI inference
- `llama-bench` — benchmarks

## Verify

```bash
./build/bin/llama-server --help 2>&1 | grep -i cuda
nvidia-smi  # confirm GPUs
```

## Quick Test

```bash
./build/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
  --host 0.0.0.0 --port 8080 \
  -ngl 35 --ctx-size 131072 --no-kv-offload
```

## Upgrade

```bash
cd /mnt/workspace/llama.cpp
git pull
rm -rf build
cmake -S . -B build \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86"
cmake --build build -j$(nproc)
```

## GPU Layout

| GPU | Device | Port | Job |
|-----|--------|------|-----|
| RTX 3060 (sm_86) | 0 | :8080 | Default, small LLMs |
| Tesla P40 (sm_61) | 1 | :8081 | Big models, `--main-gpu 1` |

## Related

- Launch wrapper: `scripts/llama-server.sh`
- Interactive model picker: `scripts/llama-loader`
- Alias: `llm='llama-loader'`

---

## Tesla P40 Considerations

The P40 (24GB, Pascal/sm_61) is good for running larger quantized LLMs via
llama.cpp but has major caveats for PyTorch-based tools like Forge:

| Limitation | Impact |
|------------|--------|
| **sm_61 not in modern torch builds** | Torch 2.11+cu130 ships sm_75+. P40 needs a custom torch build or older torch |
| **No FP16 tensor cores** | FP16 runs at ~1/2 speed (emulated). FP32 is native but more VRAM |
| **No FP8 support** | Can't use SD XL/3 optimizations that rely on FP8 |

### BIOS Quirk — P40 Won't POST Without Config First

The P40 doesn't initialize its PCIe link properly at boot unless BIOS settings
are configured *before* installing the card. If you add a P40 to a system that
has never seen it, you'll get a black screen/no POST.

**Procedure (do before installing):**

1. With the P40 not installed, boot into BIOS
2. Enable **Above 4G Decoding** (sometimes called `Above 4G MMIO`)
3. Disable **CSM** (Compatibility Support Module) — set to UEFI only
4. Enable **Resizable BAR** (if available — not strictly required but helps)
5. Save & shutdown
6. Install the P40
7. Boot — should POST now

If it still won't POST, try:
- Reseating the P40 (PCIe connection can be finicky)
- Clearing CMOS and doing step 1 again
- Some Asus boards need `PCIe Gen3` forced rather than Auto

**Once running**, confirm with:
```bash
nvidia-smi
# Should show Tesla P40 with 24GB

python -c "import torch; print(torch.cuda.get_device_properties(0))"
```

### Dual GPU — P40 + 3060 in Same PC

The 3060 (sm_86, tensor cores) keeps doing Forge/SD. The P40 (sm_61, 24GB,
no tensor cores) handles llama.cpp inference exclusively.

**Pin the P40 for llama-server:**
```bash
~/.local/bin/llama-server.sh \
  -m ~/models/<model>.gguf \
  --host 0.0.0.0 --port 8080 \
  --main-gpu 1 \        # CUDA device 1 = P40 (0 = 3060, 1 = P40)
  -ngl 64 \              # P40 has 24GB, no display overhead
  --ctx-size 131072
```

Check device ordering with `nvidia-smi` — the P40 might be device 0 or 1
depending on PCIe slot. Adjust `--main-gpu` accordingly.

**Workload split:**
| GPU | Job | Why |
|-----|-----|-----|
| RTX 3060 (12GB) | Forge/SD WebUI, small LLMs | Tensor cores, FP16 native |
| Tesla P40 (24GB) | llama.cpp big models (30B-70B Q4) | More VRAM, doesn't need FP16 |

**PyTorch on P40** — torch 2.11+cu130 doesn't include sm_61, but you don't need
it on the P40 unless you're running PyTorch-based inference there. For Forge
the 3060 handles it fine. For llama.cpp, it uses its own CUDA kernels, not
PyTorch.

### P40 Invisible in nvidia-smi — Power Cable

If the P40 is claimed by the nvidia driver (`lspci -vs 04:00.0` shows `Kernel driver in use: nvidia`) but doesn't appear in `nvidia-smi`:

```bash
dmesg | grep -i nvidia
# Look for: "GPU does not have the necessary power cables connected"
```

**Fix:** Both 8-pin power connectors must be plugged into the P40 from the PSU side (modular cables can get knocked loose when reattaching the side panel).

### P40 Invisible — PCIe Gen3 Fix (Driver Param)

If `modprobe.d` options don't apply (nvidia module loaded before config is read), use kernel cmdline instead:

```bash
# Add to kernel cmdline:
nvidia.NVreg_EnablePCIeGen3=1
```

Verify it took effect:
```bash
cat /proc/driver/nvidia/params | grep EnablePCIeGen3
# Should show: EnablePCIeGen3: 1
```

### P40 Invisible — GPU Stuck at Gen1 After Reboot

If `EnablePCIeGen3` is 1 but the card is still missing, it's almost certainly the
**power cable** (above). The PCIe Gen3 param only helps cards that have proper
power but fail link negotiation.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `CUDA error: out of memory` | Lower `-ngl` or add `--no-kv-offload` |
| `llama-server: command not found` | Build first or check path |
| Model not appearing in OpenCode | Check model ID matches filename in config |
| Slow token generation | Verify CUDA offload is working (`nvidia-smi` shows GPU usage) |
| CPU fallback (no GPU offload) | Check `sudo ldconfig -p | grep cuda` for stale library paths |
