#!/usr/bin/env bash
# ============================================================
# LLAMA-LOADER DIALECT  —  llama.cpp
# IR → CLI compiler.
#
# Reads IR from environment (set by mode scripts).
# Outputs a quoted argv string safe for eval.
# ============================================================

compile_cli() {
  local ARGS=()

  # model path
  ARGS+=(-m "$MODEL_PATH")

  # context size
  ARGS+=(-c "$CTX_SIZE")

  # GPU layers
  ARGS+=(-ngl "$NGL")

  # parallel slots
  ARGS+=(-np "$NP_VAL")

  # tensor split (dual-GPU only)
  if [[ -n "$TENSOR_SPLIT" ]]; then
    ARGS+=(--tensor-split "$TENSOR_SPLIT")
  fi

  # primary GPU index
  ARGS+=(--main-gpu "$MAIN_GPU")

  # host binding
  ARGS+=(--host 0.0.0.0)

  # port
  ARGS+=(--port "$PORT")

  # populate global CMD array
  CMD=("$LLAMA_SERVER" "${ARGS[@]}")
}
