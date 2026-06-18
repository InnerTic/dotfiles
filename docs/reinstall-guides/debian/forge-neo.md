# SD WebUI Forge Neo — Install (Debian)

CUDA 12.4 (apt) · `/mnt/workspace/sd-webui-forge-neo/`

## System Dependencies

```bash
sudo apt-get install -y libcairo2-dev pkg-config python3-dev
```

## Python Version

Debian 13 Trixie ships **Python 3.13** by default. Forge is tested with 3.10 but runs on **3.13** with `--skip-python-version-check`. Python 3.11 is also available from repos if you prefer closer to the tested version.

**Debian packages:**
```bash
# Python 3.13 (default, needs --skip-python-version-check)
sudo apt install python3 python3-venv python3-dev

# Or Python 3.11 (closer to forge's tested 3.10)
sudo apt install python3.11 python3.11-venv python3.11-dev
```

## Clone

```bash
cd /mnt/workspace
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge sd-webui-forge-neo
cd sd-webui-forge-neo
```

## Create Venv

```bash
# Python 3.13 (Debian default, needs --skip-python-version-check at launch)
python3 -m venv venv

# Or Python 3.11 (closer to forge's tested version)
python3.11 -m venv venv
```

## Install Torch (CUDA 12.4)

```bash
./venv/bin/pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu124
```

## Install xformers (build from source, matches torch 2.6)

> ⚠️ **Caution:** Must pin `xformers==0.0.29` and use `--no-build-isolation`. The default index gives 0.0.35+ which targets torch 2.10+cu128 and will crash with torch 2.6.

```bash
./venv/bin/pip install "xformers==0.0.29" --no-build-isolation
```

This takes ~5 min. Torch must be installed first (build dep).

> ⚠️ **Caution:** The `sed 's/==/>=/g'` fix is critical. Forge pins ancient versions (Pillow 9.5, numpy 1.26) that have no wheels for Python >3.10. Without this, pip tries to build them from source and fails.

## Fix requirements_versions.txt

```bash
sed -i 's/==/>=/g' requirements_versions.txt
sed -i 's/gradio>=4.40.0/gradio==4.40.0/' requirements_versions.txt
sed -i 's/huggingface-hub/huggingface-hub<0.25/' requirements_versions.txt
```

> ⚠️ **Caution:** Don't skip the gradio/huggingface-hub pins. Gradio 5 breaks forge's slider validation silently. `huggingface-hub ≥0.25` removes `HfFolder` that gradio 4.x imports at startup — crash on launch.

> ⚠️ **Caution:** `setuptools<75` is needed because some forge deps still use `pkg_resources` which was removed in setuptools ≥75. Without this pin, those packages fail to install.

## Pre-install Required Pins

```bash
./venv/bin/pip install "setuptools<75" --no-build-isolation
./venv/bin/pip install open_clip_torch
./venv/bin/pip install sentencepiece joblib
./venv/bin/pip install "gradio==4.40.0" "huggingface-hub<0.25"
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

## Launch

```bash
./venv/bin/python launch.py --listen --port 7860 --skip-python-version-check --skip-torch-cuda-test
```

First launch installs remaining deps automatically.  
`--skip-python-version-check` required when using python != 3.10.  
The svglib/pycairo warning is non-critical.

## Known Issues (Python 3.13+)

| Package | Issue | Fix |
|---------|-------|-----|
| Pillow==9.5.0 | Can't build on 3.13 | `sed -i 's/==/>=/g'` uses prebuilt wheel |
| numpy==1.26.2 | Can't build on 3.13 | Same `s/==/>=/g` fix |
| gradio 5.x | Breaks slider validation | Pin `gradio==4.40.0` |
| huggingface-hub 0.25+ | Removes `HfFolder` gradio 4.x needs | Pin `<0.25` |
| xformers | Wrong version from default index | Pin `xformers==0.0.29`, build from source |
| bitsandbytes | Needs python3-dev for Python.h | Install `python3-dev` |
| svglib/pycairo | Meson may miss venv Python | Non-critical |

## Related

- Launch script: `scripts/forge-start.sh`
- Alias: `sdxl`
