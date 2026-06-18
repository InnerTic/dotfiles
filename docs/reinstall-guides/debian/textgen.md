# TextGen WebUI (oobabooga) — Install (Debian)

CUDA 12.4 (apt) · `/mnt/workspace/textgen/`

## Python Version

Debian 13 Trixie ships **Python 3.13** by default. Textgen works fine with it — the requirements include `audioop-lts<1.0; python_version >= "3.13"` to handle the 3.13 audioop removal. Python 3.11 is also available.

**Debian packages:**
```bash
# Python 3.13 (Debian default)
sudo apt install python3 python3-venv

# Or Python 3.11
sudo apt install python3.11 python3.11-venv
```

## Clone

```bash
cd /mnt/workspace
git clone https://github.com/oobabooga/text-generation-webui textgen
cd textgen
```

## Create Venv

```bash
# Python 3.13 (Debian default)
python3 -m venv venv

# Or Python 3.11
python3.11 -m venv venv

./venv/bin/python -m pip install --upgrade pip
```

## Install CUDA Requirements (Debian — torch from cuda124 index)

```bash
./venv/bin/python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
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

## Notes

- Textgen bundles its own `llama-server` binary inside the venv — the Debian `scripts/llama-server.sh` points to this instead of a standalone build. You don't need the full llama.cpp build unless you want a standalone server.
- Uses `venv/bin/python` (not `python3`).

## Related

- llama.cpp build (optional standalone): `docs/reinstall-guides/debian/llama-cpp.md`
- Launch script: `~/.openclaw/workspace/scripts/textgen-start.sh` (if configured)
