# SD WebUI Forge Neo — Install (CachyOS)

CUDA 12.9 · `/mnt/workspace/sd-webui-forge-neo/`

## Clone

```bash
cd /mnt/workspace
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge sd-webui-forge-neo
cd sd-webui-forge-neo
```

## Python Version

CachyOS `python3` is **3.14** — forge won't build deps cleanly on it (no wheels). Use an explicit older python.

Forge is tested with **Python 3.10** but runs fine on **3.11** or **3.13** with `--skip-python-version-check`.

**CachyOS packages:**
```bash
sudo pacman -S python311  # Python 3.11 (closest to forge's tested 3.10)
sudo pacman -S python313  # Python 3.13 (current venv setup)
```

## Create Venv

```bash
# Python 3.11 (safer, closest to tested version)
python3.11 -m venv venv

# Or Python 3.13 (needs --skip-python-version-check at launch)
python3.13 -m venv venv
```

## Install Torch (CUDA 12.9)

```bash
./venv/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu129
```

## Pin Gradio 4.x (Forge doesn't work with Gradio 5)

> ⚠️ **Caution:** The `sed 's/==/>=/g'` fix is critical. Forge pins ancient versions (Pillow 9.5, numpy 1.26) that have no wheels for Python >3.10. Without this, pip tries to build them from source and fails on modern python.

Edit `requirements_versions.txt` before first launch:

```bash
sed -i 's/==/>=/g' requirements_versions.txt
sed -i 's/gradio>=4.40.0/gradio==4.40.0/' requirements_versions.txt
sed -i 's/huggingface-hub/huggingface-hub<0.25/' requirements_versions.txt
```

> ⚠️ **Caution:** Don't skip the gradio/huggingface-hub pins. Gradio 5 breaks forge's slider validation silently. `huggingface-hub ≥0.25` removes `HfFolder` that gradio 4.x imports at startup — crash on launch.

## Pre-install Fixes

```bash
./venv/bin/pip install "gradio==4.40.0" "huggingface-hub<0.25"
./venv/bin/pip install sentencepiece joblib
./venv/bin/pip install \
  "diffusers==0.31.0" \
  "transformers==4.46.1" \
  "peft==0.13.2" \
  "fastapi==0.104.1" \
  "kornia==0.6.7" \
  "accelerate==0.31.0" \
  "pydantic==2.8.2"
```

## Launch

```bash
./venv/bin/python launch.py --listen --port 7860 --theme dark --skip-python-version-check
```

First launch installs remaining deps automatically.  
`--skip-python-version-check` suppresses the "tested with 3.10" warning — required if using python != 3.10.

> ⚠️ **Caution:** First launch downloads model files and can take a while. If it fails on a dep, check the Known Issues table in the Debian forge-neo guide — same fixes apply on CachyOS.

## Related

- Launch script: `scripts/forge-start.sh`
- Alias: `sdxl`
