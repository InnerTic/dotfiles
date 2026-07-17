#!/bin/bash
# CachyOS/Arch — uses local CUDA build (supports sm_61 + sm_86, both GPUs)
LLAMA_BIN="/mnt/workspace/llama.cpp/build/bin"
LLAMA_BIN="/mnt/workspace/llama.cpp/build/bin"
export LD_LIBRARY_PATH="$LLAMA_BIN:$LD_LIBRARY_PATH"
exec "$LLAMA_BIN/llama-server" "$@"
