#!/usr/bin/env bash
# ============================================================
# LLAMA-LOADER IR  —  Intermediate Representation
# PURE VALUES ONLY.  NO CLI FLAGS.  EVER.
# ============================================================
# IR contract (all optional — defaults below):
NP_VAL="${NP_VAL:-1}"
NGL="${NGL:-60}"
CTX_SIZE="${CTX_SIZE:-32768}"
TENSOR_SPLIT="${TENSOR_SPLIT:-}"
MAIN_GPU="${MAIN_GPU:-0}"
PORT="${PORT:-8080}"
MODEL_PATH="${MODEL_PATH:-}"
NP_MODE="${NP_MODE:-manual}"
GPU_MODE_LABEL="${GPU_MODE_LABEL:-}"
REASONING="${REASONING:-on}"

# Multimodal projector (mmproj) — vision/audio models only. Empty = none.
# MMPROJ is the absolute path to the projector file.
# MMPROJ_DEVICE pins the projector to a specific GPU (e.g. CUDA0) or
# "none"/"cpu" to keep it on the CPU. Empty = follow llama.cpp default.
MMPROJ="${MMPROJ:-}"
MMPROJ_DEVICE="${MMPROJ_DEVICE:-}"

# MODEL_DEVICE restricts the whole model to a single backend device
# (e.g. CUDA1). Empty = spread across all available GPUs.
MODEL_DEVICE="${MODEL_DEVICE:-}"

# Extra arguments — structured array, not a string.
# Each element is one CLI token. Values that take args are separate elements:
#   EXTRA_ARGS=("--cache-type-k" "q8_0" "--jinja")
EXTRA_ARGS=("${EXTRA_ARGS[@]}")

# MCP servers config path — empty means disabled.
MCP_CONFIG="${MCP_CONFIG:-}"
