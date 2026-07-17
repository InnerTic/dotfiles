#!/bin/bash
# Start TextGen WebUI (oobabooga)
cd /mnt/workspace/textgen
exec ./venv/bin/python server.py --listen --listen-port 7861 --api "$@"
