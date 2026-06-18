# TextGen WebUI (oobabooga) — Install (CachyOS)

CUDA 12.9 · `/mnt/workspace/textgen/`

## Clone

```bash
cd /mnt/workspace
git clone https://github.com/oobabooga/text-generation-webui textgen
cd textgen
```

## Python Version

CachyOS `python3` is **3.14** — textgen's dep wheels may not all exist for it yet. Use an explicit older python.

Textgen works with **Python 3.11** or **3.13** — the requirements include `audioop-lts<1.0; python_version >= "3.13"` to handle the 3.13 audioop removal.

**CachyOS packages:**
```bash
sudo pacman -S python313  # Python 3.13 (recommended)
sudo pacman -S python311  # Python 3.11 (alternative)
```

## Create Venv

```bash
# Python 3.13 (recommended, good wheel support)
python3.13 -m venv venv

# Or Python 3.11
python3.11 -m venv venv

./venv/bin/python -m pip install --upgrade pip
```

## Install CUDA Requirements (CachyOS — torch from cuda129 index)

```bash
./venv/bin/python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu129
./venv/bin/python -m pip install -r requirements/full/requirements.txt
```

Or use the auto-installer:
```bash
./start_linux.sh --listen
```

> ⚠️ **Caution:** The auto-installer (`start_linux.sh`) creates its own venv. If you already created one manually, it will detect and reuse it. Make sure you created it with the right python version (see above).

## Symlink Models

```bash
ln -s ~/Downloads/llm_models /mnt/workspace/textgen/user_data/models
```

## Launch

```bash
cd /mnt/workspace/textgen
./venv/bin/python server.py --listen --listen-port 7861 --api
```

## Related

- Textgen bundles its own llama-server binary inside the venv
- llama.cpp build is separate (see llama-cpp.md) if you want a standalone server
