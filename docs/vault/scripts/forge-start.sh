#!/bin/bash
# Debian — Start SD WebUI Forge Neo
VENV_PYTHON="/mnt/workspace/sd-webui-forge-neo/venv/bin/python3"
cd /mnt/workspace/sd-webui-forge-neo
exec "$VENV_PYTHON" launch.py --listen --port 7860 --theme dark --skip-python-version-check --enable-insecure-extension-access --medvram "$@"