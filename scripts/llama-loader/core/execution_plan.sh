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
