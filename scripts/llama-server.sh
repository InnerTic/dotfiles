#!/bin/bash
# Debian — uses textgen-bundled llama-server (Arch build-cuda12 needs glibc 2.43)
LLAMA_BIN="/mnt/workspace/textgen/venv/lib/python3.13/site-packages/llama_cpp_binaries/bin"
export LD_LIBRARY_PATH="$LLAMA_BIN:$LD_LIBRARY_PATH"
exec "$LLAMA_BIN/llama-server" "$@"
