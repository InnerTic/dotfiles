#!/bin/bash
export CUDA_PATH=/opt/cuda
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
exec /mnt/workspace/llama.cpp/build/bin/llama-server "$@"
