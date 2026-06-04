# llama.cpp — Fresh Install to Running Server

CUDA 13.3 · sm_86 (RTX 3060) · CachyOS/Arch

## 1. System Dependencies

```bash
sudo pacman -S --needed base-devel cmake cuda git
```

## 2. Clone & Build

```bash
cd ~/workspace
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
mkdir build && cd build
cmake .. -DLLAMA_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=86
make -j$(nproc)
```

This produces binaries in `build/bin/`:
- `llama-server` — main server (OpenAI-compatible API on :8080)
- `llama-cli` — CLI inference
- `llama-bench` — benchmarking
- `llama-quantize` — quantize models

## 3. Verify CUDA Offload

```bash
./build/bin/llama-server --help 2>&1 | grep -i cuda
# Should show CUDA support compiled in
```

## 4. Get GGUF Models

Place `.gguf` files in `~/Downloads/llm_models/`.

Common sources:
- HuggingFace: `huggingface.co/<user>/<repo>`
- unsloth, bartowski, mradermacher repos

## 5. Start Server

```bash
~/workspace/llama.cpp/build/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
  --host 0.0.0.0 \
  --port 8080 \
  -ngl 35 \
  --ctx-size 131072 \
  --no-kv-offload \
  -np 8 \
  --jinja
```

| Flag | Meaning |
|------|---------|
| `-ngl 35` | Offload 35 layers to GPU (fits 7B-8B on 12GB VRAM) |
| `--no-kv-offload` | KV cache on system RAM, saves VRAM |
| `--ctx-size 131072` | 128K context window |
| `-np 8` | 8 parallel processing slots |
| `--jinja` | Jinja2 chat template support |

## 6. Verify Running

```bash
curl http://127.0.0.1:8080/v1/models
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"<model-filename>","messages":[{"role":"user","content":"hello"}]}'
```

## 7. Configure in OpenCode

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

## 8. Quick Aliases (in ~/.zshrc)

```zsh
alias llm='llama-loader'                                                    # Interactive model selector
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'
```

## 9. Upgrade

```bash
cd ~/workspace/llama.cpp
git pull
cd build
cmake .. -DLLAMA_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=86
make -j$(nproc)
```

## CUDA Version Gotchas

System CUDA (`/opt/cuda`) updates with `pacman -Syu`. This is fine for llama.cpp
(built from source each time), but **PyTorch / oobabooga / text-gen venvs** are
installed via pip wheels pinned to a specific CUDA version (e.g. `cu124`, `cu128`).

If system CUDA updates but the venv's torch wheel was compiled against an older
CUDA, inference silently falls back to CPU or errors out.

**Fix:** Recreate the venv or reinstall torch matching the new CUDA:

```bash
pip install --force-reinstall torch torchvision --index-url https://download.pytorch.org/whl/cu133
```

Check the venv's `lib/python3.x/site-packages/torch/version.py` to see what CUDA
it was built against.

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

**Build for both architectures:**
```bash
cd ~/workspace/llama.cpp/build
cmake .. -DLLAMA_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="61;86"
make -j$(nproc)
```

**Pin the P40 for llama-server:**
```bash
~/workspace/llama.cpp/build/bin/llama-server \
  -m ~/Downloads/llm_models/<model>.gguf \
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

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `CUDA error: out of memory` | Lower `-ngl` or add `--no-kv-offload` |
| `llama-server: command not found` | Build first (step 2) or check path |
| Model not appearing in OpenCode | Check model ID matches filename in config |
| Slow token generation | Verify CUDA offload is working (`nvidia-smi` shows GPU usage) |
| `cmake: not found` | `sudo pacman -S cmake` |
