# llama.cpp — Install (Debian)

CUDA 12.4 (apt) · sm_61 + sm_86 (RTX 3060 + Tesla P40)

## Prerequisites

```bash
sudo apt update
sudo apt install -y build-essential cmake git nvidia-cuda-toolkit
```

`nvidia-cuda-toolkit` provides CUDA 12.4 from the Debian repo. nvcc lands at `/usr/bin/nvcc`.

> ⚠️ **Caution:** Driver may report CUDA 13.0 runtime but the *toolkit* is 12.4 — that's fine. Don't try to install CUDA 12.9 on Debian, it's not in repos and the build works with 12.4.
>
> ⚠️ **Caution:** Build artifacts link against glibc 2.41. They will NOT run on CachyOS (glibc 2.43). Always rebuild per-distro.

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

System nvcc (CUDA 12.4) and system GCC are on PATH — cmake finds them automatically.

Build outputs in `build/bin/`.

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

## Notes

- Debian has glibc 2.41 — builds from Arch (glibc 2.43) won't run here. Always build from source on Debian.
- CUDA 12.4 is the latest available from Debian repos. Driver may report CUDA 13.0 runtime but toolkit 12.4 is sufficient.
- No special GCC or patches needed — Debian's nvidia-cuda-toolkit is compatible with system GCC.

## Related

- Launch wrapper: `scripts/llama-server.sh`
- Interactive model picker: `scripts/llama-loader`
- Alias: `llm='llama-loader'`
