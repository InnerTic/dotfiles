# SD WebUI Forge Neo

CUDA 12.4 (Debian) / 12.9 (CachyOS) · `/mnt/workspace/sd-webui-forge-neo/`

## Debian

### System Dependencies

```bash
sudo apt-get install -y libcairo2-dev pkg-config python3-dev
```

### Python Version

Debian 13 Trixie ships **Python 3.13** by default. Forge runs with `--skip-python-version-check`. Python 3.11 also available:

```bash
sudo apt install python3 python3-venv python3-dev
# Or: sudo apt install python3.11 python3.11-venv python3.11-dev
```

### Clone

```bash
cd /mnt/workspace
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge sd-webui-forge-neo
cd sd-webui-forge-neo
```

### Create Venv

```bash
python3 -m venv venv
```

### Install Torch (CUDA 12.4)

```bash
./venv/bin/pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu124
```

### Install xformers

Pin `xformers==0.0.29` and use `--no-build-isolation`. The default index gives 0.0.35+ which targets torch 2.10+cu128 and will crash with torch 2.6.

```bash
./venv/bin/pip install "xformers==0.0.29" --no-build-isolation
```

### Fix requirements_versions.txt

```bash
sed -i 's/==/>=/g' requirements_versions.txt
sed -i 's/gradio>=4.40.0/gradio==4.40.0/' requirements_versions.txt
sed -i 's/huggingface-hub/huggingface-hub<0.25/' requirements_versions.txt
```

### Pre-install Required Pins

```bash
./venv/bin/pip install "setuptools<75" --no-build-isolation
./venv/bin/pip install open_clip_torch sentencepiece joblib
./venv/bin/pip install "gradio==4.40.0" "huggingface-hub<0.25"
./venv/bin/pip install \
  "diffusers==0.31.0" "transformers==4.46.1" "peft==0.13.2" \
  "fastapi==0.104.1" "kornia==0.6.7" "accelerate==0.31.0" \
  "pydantic==2.8.2" "protobuf==3.20.0"
```

### Launch

```bash
./venv/bin/python launch.py --listen --port 7860 --skip-python-version-check --skip-torch-cuda-test
```

## CachyOS

### Python Version

CachyOS `python3` is 3.14. Use an explicit older python:

```bash
sudo pacman -S python311  # closest to forge's tested 3.10
sudo pacman -S python313  # current venv setup
```

### Clone

```bash
cd /mnt/workspace
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge sd-webui-forge-neo
cd sd-webui-forge-neo
```

### Create Venv

```bash
python3.13 -m venv venv
```

### Install Torch (CUDA 12.9)

```bash
./venv/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu129
```

### Fix requirements_versions.txt

```bash
sed -i 's/==/>=/g' requirements_versions.txt
sed -i 's/gradio>=4.40.0/gradio==4.40.0/' requirements_versions.txt
sed -i 's/huggingface-hub/huggingface-hub<0.25/' requirements_versions.txt
```

### Pre-install Fixes

```bash
./venv/bin/pip install "gradio==4.40.0" "huggingface-hub<0.25"
./venv/bin/pip install sentencepiece joblib
./venv/bin/pip install \
  "diffusers==0.31.0" "transformers==4.46.1" "peft==0.13.2" \
  "fastapi==0.104.1" "kornia==0.6.7" "accelerate==0.31.0" \
  "pydantic==2.8.2"
```

### Launch

```bash
./venv/bin/python launch.py --listen --port 7860 --theme dark --skip-python-version-check
```

## Known Issues

| Package | Issue | Fix |
|---------|-------|-----|
| Pillow==9.5.0 | Can't build on 3.13+ | `sed -i 's/==/>=/g'` uses prebuilt wheel |
| numpy==1.26.2 | Can't build on 3.13+ | Same `s/==/>=/g` fix |
| gradio 5.x | Breaks slider validation | Pin `gradio==4.40.0` |
| huggingface-hub 0.25+ | Removes `HfFolder` gradio 4.x needs | Pin `<0.25` |
| xformers | Wrong version from default index | Pin `xformers==0.0.29`, build from source |
| bitsandbytes | Needs python3-dev for Python.h | Install `python3-dev` |
| svglib/pycairo | Meson may miss venv Python | Non-critical |

## Related

- Launch script: `scripts/forge-start.sh`
- Alias: `sdxl`
