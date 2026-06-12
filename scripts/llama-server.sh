#!/bin/bash
export CUDA_PATH=/home/ken/.local/cuda-12.9
export LD_LIBRARY_PATH=/home/ken/.local/cuda-12.9/lib64:$LD_LIBRARY_PATH
exec /home/ken/workspace/llama.cpp/build-cuda12/bin/llama-server "$@"
