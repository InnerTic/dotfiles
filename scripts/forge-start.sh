#!/bin/bash
# Debian — Start SD WebUI Forge Neo
cd /mnt/workspace/sd-webui-forge-neo
python3 launch.py --listen --port 7860 "$@"