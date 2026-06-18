# llama.cpp — Install (CachyOS)

CUDA 12.9 · sm_61 + sm_86 (RTX 3060 + Tesla P40)

## Prerequisites

```bash
sudo pacman -S --needed base-devel cmake git cuda-12.9
```

CUDA 12.9 lands at `/opt/cuda/`. System GCC (16) works fine as host compiler.

> ⚠️ **Caution:** Build artifacts link against glibc 2.43 (CachyOS). They will NOT run on Debian (glibc 2.41). Always rebuild per-distro.
>
> ⚠️ **Caution:** Don't use the old `~/.local/cuda-12.4` install — it conflicts at runtime. If llama-server falls back to CPU, check `sudo ldconfig -p | grep cuda` for stale library paths.

## Clone & Build

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

Build outputs in `build/bin/`:
- `llama-server` — main server
- `llama-cli` — CLI inference
- `llama-bench` — benchmarks

> ⚠️ **Caution:** GPU device order (0 vs 1) depends on PCIe slot, not GPU model. Check with `nvidia-smi` before using `--main-gpu`.

## Verify CUDA Offload

```bash
./build/bin/llama-server --help 2>&1 | grep -i cuda
nvidia-smi  # confirm both GPUs visible
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
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCUDAToolkit_ROOT=/opt/cuda
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
