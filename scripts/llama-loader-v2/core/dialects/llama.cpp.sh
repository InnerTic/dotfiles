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

  # GPU placement:
  #   MODEL_DEVICE set -> pin the WHOLE model to one backend (e.g. CUDA1)
  #   otherwise        -> multi-GPU: tensor-split + main-gpu
  if [[ -n "$MODEL_DEVICE" ]]; then
    ARGS+=(--device "$MODEL_DEVICE")
  else
    # tensor split (dual-GPU only)
    if [[ -n "$TENSOR_SPLIT" ]]; then
      ARGS+=(--tensor-split "$TENSOR_SPLIT")
    fi
    # primary GPU index
    ARGS+=(--main-gpu "$MAIN_GPU")
  fi

  # host binding
  ARGS+=(--host 0.0.0.0)

  # port
  ARGS+=(--port "$PORT")

  # thinking mode (model-aware: Gemma 4 defaults to off, else on)
  if [[ "$REASONING" == "off" ]]; then
    ARGS+=(--reasoning off)
  fi

  # multimodal projector (vision/audio models) — independent GPU placement
  if [[ -n "$MMPROJ" && -f "$MMPROJ" ]]; then
    ARGS+=(--mmproj "$MMPROJ")

    if [[ -n "$MMPROJ_DEVICE" ]]; then
      case "$MMPROJ_DEVICE" in
        none|cpu|CPU|off)
          ARGS+=(--no-mmproj-offload)
          ;;
        *)
          if llama_supports_flag "--mmproj-device"; then
            ARGS+=(--mmproj-device "$MMPROJ_DEVICE")
          else
            echo "WARNING: llama.cpp build lacks --mmproj-device — rebuild to pin the projector; it will follow --device" >&2
          fi
          ;;
      esac
    fi
  fi

  # MCP servers config (Cursor-compatible format)
  if [[ -n "$MCP_CONFIG" && -f "$MCP_CONFIG" ]]; then
    ARGS+=(--mcp-servers-config "$MCP_CONFIG")
    ARGS+=(--tools all)
  fi

  # Extra arguments — each element is one CLI token.
  # This is the escape hatch: model-specific, experimental, or
  # version-dependent flags that don't warrant a first-class IR field.
  if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    ARGS+=("${EXTRA_ARGS[@]}")
  fi

  # populate global CMD array
  CMD=("$LLAMA_SERVER" "${ARGS[@]}")
}
