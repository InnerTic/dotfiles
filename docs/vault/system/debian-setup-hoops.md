# Debian 13 Trixie Setup — All the Hoops

This document records every workaround needed to get Arch/CachyOS dotfiles working on Debian 13 (Trixie).

## 1. dotfiles Branch

Three branches exist:
- `main` — Arch/CachyOS version. Pacman, `/opt/cuda`, glibc 2.43.
- `deb` — Debian 13 version. Apt, no `/opt/cuda`, glibc 2.41.

Switch with: `git checkout deb`

## 2. fstab — Mount 4 Drives + 8 Bind Mounts

In `/etc/fstab`, mount drives by UUID (not `/dev/sdX` — those change on reboot).

Find UUIDs with: `blkid`

Drives:
- `/dev/disk/by-uuid/930A20DB0A20BB6D` → `/mnt/ssd_storage` (ntfs-3g)
- `/dev/disk/by-uuid/B8763EAB763E6A15` → `/mnt/data` (ntfs-3g)
- `/dev/disk/by-uuid/D4B048DFB048C733` → `/mnt/m2_storage` (ntfs-3g)
- `/dev/disk/by-uuid/45CD93E2614CE44B` → `/mnt/workspace` (ext4)

Bind mounts:
- `/mnt/ssd_storage/Models` → `/mnt/workspace/models`
- `/mnt/ssd_storage/stable_diffusion` → `/mnt/workspace/stable_diffusion`
- `/mnt/ssd_storage/datasets` → `/mnt/workspace/datasets`
- `/mnt/data/Documents` → `/mnt/workspace/docs`
- `/mnt/data/Github` → `/mnt/workspace/github`
- `/mnt/m2_storage/Downloads` → `/mnt/workspace/downloads`
- `/mnt/m2_storage/backups` → `/mnt/workspace/backups`
- `/mnt/ssd_storage` → `/mnt/workspace/ssd_storage`

Apply: `sudo mount -a`

Symlink: `sudo ln -s /mnt/workspace /workspace`

## 3. llama.cpp — Build from Source

**Do NOT use `build-cuda12/` from Arch** — it needs glibc 2.43, Debian has 2.41.

```bash
cd /mnt/workspace
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
mkdir build && cd build
cmake .. -DLLAMA_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="52;61"
make -j$(nproc)
sudo make install  # optional, puts binary in /usr/local/bin
```

On Debian 13, `nvidia-cuda-toolkit` from repos provides `/usr/bin/nvcc` (CUDA 12.4).
Driver shows CUDA 13.0 runtime (580.142) but toolkit 12.4 is sufficient.

## 4. TextGen WebUI (oobabooga)

Path: `/mnt/workspace/textgen/`
Venv: `/mnt/workspace/textgen/venv/`

### Install

```bash
cd /mnt/workspace
git clone https://github.com/oobabooga/text-generation-webui textgen
cd textgen
python3 -m venv venv
./venv/bin/python -m pip install --upgrade pip
```

CUDA requirements (use the cuda131 file — it's actually CUDA 12.4 compatible):

```bash
./venv/bin/python -m pip install -r requirements_cuda131.txt
```

### Notes
- Uses `python` (not `python3`) in the venv — the `textgen-start.sh` script calls `venv/bin/python`.
- Model path symlink: `ln -s ~/Downloads/llm_models /mnt/workspace/textgen/user_data/models`
- Textgen bundles its own `llama-server` binary — the Debian `llama-server.sh` script in dotfiles points to this instead of the Arch `build-cuda12/` binary.

## 5. llama-server.sh

The dotfiles script at `scripts/llama-server.sh` uses `/mnt/workspace/textgen/venv/bin/llama-server` (textgen-bundled binary) instead of the now-nonexistent `build-cuda12` directory.

For testing with a model:
```bash
~/dotfiles/scripts/llama-server.sh ~/Downloads/llm_models/qwen-14b.Q4_K_M.gguf
```

## 6. SD WebUI Forge Neo

Path: `/mnt/workspace/sd-webui-forge-neo/`
Venv: `/mnt/workspace/sd-webui-forge-neo/venv/`

### Install

```bash
cd /mnt/workspace
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge sd-webui-forge-neo
cd sd-webui-forge-neo
python3 -m venv venv
```

Install torch with CUDA 12.4 support:

```bash
./venv/bin/pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu124
```

Install matching xformers (must match torch version — latest xformers from torch index targets torch 2.10 and will crash):

```bash
# DO NOT use: pip install xformers --index-url ... (gets wrong version for torch 2.6)
./venv/bin/pip install "xformers==0.0.29" --no-build-isolation
# This builds from source, takes ~5 min. Must have torch installed first (build dep).
```

Install CLIP (needs `setuptools<75` for `pkg_resources` compat + `--no-build-isolation`):

```bash
./venv/bin/pip install "setuptools<75" --no-build-isolation
```

Install remaining deps:

```bash
./venv/bin/pip install open_clip_torch
```

### The `requirements_versions.txt` Problem

Forge pins every dependency to an exact version (e.g. `Pillow==9.5.0`, `numpy==1.26.2`).
These are too old for Python 3.13 and fail to compile.

**Fix**: Change all `==` to `>=` so pip doesn't try to downgrade, then selectively re-pin the packages that need fixed versions for compatibility:

```bash
cd /mnt/workspace/sd-webui-forge-neo
sed -i 's/==/>=/g' requirements_versions.txt
```

### System packages needed

```bash
sudo apt-get install -y libcairo2-dev pkg-config python3-dev
```

### Venv fixes before first launch

```bash
# pre-install what forge's installer will fail on
./venv/bin/pip install sentencepiece joblib

# pin gradio to 4.x (5.x breaks slider validation, incompatible with forge UI)
# but 4.40.0 exact works on Python 3.13
./venv/bin/pip install "gradio==4.40.0"

# pin huggingface-hub <0.25 (gradio 4.x imports HfFolder, removed in 0.25+)
./venv/bin/pip install "huggingface-hub<0.25"

# re-pin specific versions that conflict with older huggingface-hub
./venv/bin/pip install \
  "diffusers==0.31.0" \
  "transformers==4.46.1" \
  "peft==0.13.2" \
  "fastapi==0.104.1" \
  "kornia==0.6.7" \
  "accelerate==0.31.0" \
  "pydantic==2.8.2" \
  "protobuf==3.20.0"
```

Update `requirements_versions.txt` to reflect the gradio pin:

```bash
sed -i 's/gradio>=4.40.0/gradio==4.40.0/' requirements_versions.txt
sed -i 's/huggingface-hub/huggingface-hub<0.25/' requirements_versions.txt
```

### Launch

```bash
./venv/bin/python3 launch.py --listen --port 7860 --skip-python-version-check --skip-torch-cuda-test
```

### Python 3.13 Issues (logged during the process)
- `setuptools==69.5.1` → un-pin, installed version 74+ works fine.
- `Pillow==9.5.0` → can't build on 3.13 (`KeyError: '__version__'`). Pillow 11+ works.
- `numpy==1.26.2` → can't build on 3.13 without `python3-dev`. The >= pin uses prebuilt wheel.
- `scikit-image==0.21.0` → can't build on 3.13 either. Leave unpinned.
- `svglib`/`pycairo` → needs `libcairo2-dev`, `pkg-config`, **and** `python3-dev` for `Python.h`. Even then, pycairo 1.29 meson build may fail to find Python in the venv. **Non-critical** — only needed for SVG preprocessors.
- `bitsandbytes` → needs `python3-dev` for `Python.h`. **Optional** — only for 4-bit quantization.
- `xformers` → wrong version from default index (0.0.35 targets torch 2.10+cu128). Must pin `xformers==0.0.29` and build from source with `--no-build-isolation`. Needs torch installed first.
- `gradio` → 5.x breaks forge slider validation. Pin to `==4.40.0`.
- `huggingface-hub` → 0.25+ removes `HfFolder` which gradio 4.x imports. Pin `<0.25`.
- `diffusers`, `transformers`, `peft`, etc. → new versions require huggingface-hub >=0.25. Re-pin to forge's original versions (`0.31.0`, `4.46.1`, `0.13.2`).
- `insightface` → optional preprocessor, install manually if needed: `pip install insightface`
- `joblib` → needed by `soft_inpainting.py` script

## 7. Shell Configs

- `shell/.zshrc` — CachyOS `source` lines commented out. `sdxl` alias → `~/dotfiles/scripts/forge-start.sh`.
- `shell/config.fish` — CachyOS source lines commented out.
- `~/.bashrc` — AI aliases added directly (backup for bash sessions).
- `~/.local/bin/` — symlinks: `llama-loader`, `forge-start`, `healthcheck`, `llama-server.sh`.

## 8. Converted Scripts (pacman → apt)

| Script | Key Changes |
|--------|-------------|
| `scripts/check-fixes.sh` | `pacman -Q` → `dpkg -l` |
| `scripts/healthcheck.sh` | `pacman -Q` → `dpkg -l` |
| `scripts/live-env-setup.sh` | Full rewrite: `pacman` → `apt`, `arch-chroot` → `chroot` |
| `scripts/forge-start.sh` | New file, uses venv python |
| `docs/system_backup/REBUILD_SCRIPT.sh` | Full Debian rewrite |
| `docs/system_backup/pkglist-apps.txt` | Debian package names |

## 9. SSH

```bash
ln -s /mnt/workspace/.ssh ~/.ssh
```

This makes GitHub auth work from any shell.

## 10. Quick Reference

| What | Command |
|------|---------|
| Start Forge | `sdxl` (alias in .zshrc/.bashrc) |
| Start TextGen | `textgen-start.sh` |
| Start llama server | `llama-server.sh <model>` |
| List models | `llama-loader` |

## 11. Final Steps

- [x] Run `sudo apt-get install -y libcairo2-dev pkg-config python3-dev`
- [x] Run forge once, let it install preprocessor deps (svglib warning is non-critical)
- [x] Install `sentencepiece` + `joblib` in forge venv
- [ ] Install remaining desktop apps from `docs/system_backup/pkglist-apps.txt` (alacritty, btop, nvtop, fastfetch, virt-manager, etc.)
- [ ] Download SDXL base models from within Forge UI at http://127.0.0.1:7860
- [ ] Test `llm` alias with actual inference (start llama-server, point textgen at it)
- [ ] Optionally serve `gpt-oss-20b-hermes` on port 8081 (Tesla P40, `--main-gpu 1`)
- [ ] Forge currently warns about `soft_inpainting.py` missing `joblib` — already fixed by pre-install above
