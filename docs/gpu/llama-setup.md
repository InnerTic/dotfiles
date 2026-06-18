# llama.cpp — Fresh Install to Running Server

CUDA 12.4 · sm_61 + sm_86 (RTX 3060 + Tesla P40) · CachyOS/Arch / Debian

> **Debian:** On Debian, skip the `pacman` steps and use `apt` equivalents.
> The `llama-server.sh` script already points to the textgen-bundled binary
> which works with glibc 2.41. The standalone build-cuda12 was built on Arch
> (glibc 2.43) and won't run here — rebuild from source if you want it.

## 1. System Dependencies

```bash
sudo pacman -S --needed base-devel cmake git
```

CUDA 12.4 is not installed from pacman (system CUDA 13+ drops sm_61/Pascal support).
Install it locally — see step 2.

GCC 9 is required as the CUDA 12.4 host compiler:

```bash
pkexec pacman -S --noconfirm cachyos/gcc9
```


`cuda 12.4 is wrong on cachos and needs to be changed to 12.9. 12,4 is the only thing that depends older gcc9 and craps out on 15/16. 12.4 is for debain its in the repo, 12.9 for deb is not in repo`
## 2. Install CUDA 12.4 Toolkit

```bash
curl -L "https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_550.54.14_linux.run" \
  -o /tmp/cuda_12.4.0_linux.run
chmod +x /tmp/cuda_12.4.0_linux.run
pkexec /tmp/cuda_12.4.0_linux.run \
  --toolkit \
  --toolkitpath=/home/ken/.local/cuda-12.4 \
  --silent \
  --override
```

## 3. Patch math_functions.h (glibc ≥2.41 noexcept conflict)

CUDA 12.4's `math_functions.h` declares functions without `__THROW`/`noexcept`,
but modern glibc declares them with `noexcept (true)`. Patch the conflicts:

Note: the CUDA toolkit is root-owned, so patches need `sudo`.

```bash
sudo sed -i '847s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float rsqrtf(float x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float rsqrtf(float x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
sudo sed -i '777s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double rsqrt(double x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double rsqrt(double x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
sudo sed -i '5554s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double cospi(double x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double cospi(double x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
sudo sed -i '5606s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float cospif(float x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float cospif(float x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
sudo sed -i '5442s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double sinpi(double x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double sinpi(double x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
sudo sed -i '5502s/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float sinpif(float x);/extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ float sinpif(float x) __THROW;/' /home/ken/.local/cuda-12.4/include/crt/math_functions.h
```

## 4. nvcc-cmake Wrapper

Create a wrapper so CMake can detect CUDA 12.4 with GCC 9 as the host compiler:

```bash
sudo tee /home/ken/.local/cuda-12.4/bin/nvcc-cmake > /dev/null << 'WRAPPER'
#!/bin/bash
export CUDA_PATH=/home/ken/.local/cuda-12.4
exec /home/ken/.local/cuda-12.4/bin/nvcc \
  -ccbin /usr/bin/gcc-9 \
  --std=c++14 \
  -I/home/ken/.local/cuda-12.4/include \
  "$@"
WRAPPER
sudo chmod +x /home/ken/.local/cuda-12.4/bin/nvcc-cmake
```

## 5. Clone & Build

The dual-arch flags (`sm_61 + sm_86`) compile CUDA kernels for **both** Pascal
and Ampere in one binary. You do **not** need both GPUs present to run — the
binary works fine with either card alone.

```bash
cd ~/workspace
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
rm -rf build-cuda12
cmake -S . -B build-cuda12 \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCMAKE_CUDA_COMPILER=/home/ken/.local/cuda-12.4/bin/nvcc-cmake \
  -DCUDAToolkit_ROOT=/home/ken/.local/cuda-12.4
cmake --build build-cuda12 -j$(nproc)
```

This produces binaries in `build-cuda12/bin/`:
- `llama-server` — main server (OpenAI-compatible API on :8080)
- `llama-cli` — CLI inference
- `llama-bench` — benchmarking
- `llama-quantize` — quantize models

## 6. Verify CUDA Offload

```bash
./build-cuda12/bin/llama-server --help 2>&1 | grep -i cuda
```

## 7. Get GGUF Models

Place `.gguf` files in `~/Downloads/llm_models/`.

Common sources:
- HuggingFace: `huggingface.co/<user>/<repo>`
- unsloth, bartowski, mradermacher repos

## 8. Start Server

```bash
export LD_LIBRARY_PATH=/home/ken/.local/cuda-12.4/lib64:$LD_LIBRARY_PATH
~/workspace/llama.cpp/build-cuda12/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
  --host 0.0.0.0 \
  --port 8080 \
  -ngl 35 \
  --ctx-size 131072 \
  --no-kv-offload \
  -np 8 \
  --jinja
```

Or use the launcher script:

```bash
~/dotfiles/scripts/llama-server.sh -m ~/models/<model>.gguf --main-gpu 1 -ngl 64
```

| Flag | Meaning |
|------|---------|
| `-ngl 35` | Offload 35 layers to GPU (fits 7B-8B on 12GB VRAM) |
| `--no-kv-offload` | KV cache on system RAM, saves VRAM |
| `--ctx-size 131072` | 128K context window |
| `-np 8` | 8 parallel processing slots |
| `--jinja` | Jinja2 chat template support |

## 9. Verify Running

```bash
curl http://127.0.0.1:8080/v1/models
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"<model-filename>","messages":[{"role":"user","content":"hello"}]}'
```

## 10. Configure in OpenCode

`~/.config/opencode/opencode.json`:

```json
{
  "provider": {
    "id": "llama.cpp",
    "url": "http://127.0.0.1:8080/v1",
    "models": {
      "<model-filename>": {}
    }
  }
}
```

Then in TUI: `/model llama.cpp/<model-filename>`

## 11. Quick Aliases

```zsh
alias llm='llama-loader'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'
```

## 12. Upgrade

```bash
cd ~/workspace/llama.cpp
git pull
rm -rf build-cuda12
cmake -S . -B build-cuda12 \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCMAKE_CUDA_COMPILER=/home/ken/.local/cuda-12.4/bin/nvcc-cmake \
  -DCUDAToolkit_ROOT=/home/ken/.local/cuda-12.4
cmake --build build-cuda12 -j$(nproc)
```

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

   *On CachyOS/Arch — this is in Advanced → PCI Subsystem Settings*

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

On CachyOS, `modprobe.d` options may not apply (nvidia module loaded before config is read). Use kernel cmdline instead:

```bash
# Add to /boot/limine.conf cmdline:
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

## General Troubleshooting

| Symptom | Fix |
|---------|-----|
| `CUDA error: out of memory` | Lower `-ngl` or add `--no-kv-offload` |
| `llama-server: command not found` | Build first (step 5) or check path |
| Model not appearing in OpenCode | Check model ID matches filename in config |
| Slow token generation | Verify CUDA offload is working (`nvidia-smi` shows GPU usage) |
| `cmake: not found` | `sudo pacman -S cmake` |
