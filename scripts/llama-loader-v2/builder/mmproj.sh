# ============================================================
# BUILDER: MMPROJ (multimodal projector)
# Attach / detach the projector for vision & audio models and
# pin the encoder to a GPU independently of the model.
#
# Requires llama.cpp with `--mmproj-device` (PR #23255) to place
# the encoder on a different device than the model.
# ============================================================

mmproj_select_device() {
  echo
  echo "  Encoder device:"
  echo "    1) CUDA0  (RTX 3060 — fastest for the vision encoder)"
  echo "    2) CUDA1  (Tesla P40 — large VRAM)"
  echo "    3) CPU    (no offload)"
  echo "  Enter) keep current"
  read -p "Choice: " d || true
  case "$d" in
    1) MMPROJ_DEVICE="CUDA0" ;;
    2) MMPROJ_DEVICE="CUDA1" ;;
    3) MMPROJ_DEVICE="none" ;;
    "") : ;;
    *) echo "Invalid choice" ;;
  esac

  if [ -n "$MMPROJ_DEVICE" ] && [ "$MMPROJ_DEVICE" != "none" ] \
     && ! llama_supports_flag "--mmproj-device"; then
    echo
    echo "WARNING: installed llama-server lacks --mmproj-device."
    echo "         Rebuild llama.cpp to pin the encoder; it will otherwise"
    echo "         follow --device."
  fi
}

mmproj_menu() {
  while true; do
    local detected
    detected="$(find_mmproj_for_model "$SELECTED")"

    echo
    echo "=============================================="
    echo " MULTIMODAL PROJECTOR (mmproj)"
    echo "=============================================="
    if [ -n "$MMPROJ" ]; then
      echo "  current : ${MMPROJ##*/}"
      echo "  encoder : ${MMPROJ_DEVICE:-<default>}"
    else
      echo "  current : [none]"
    fi
    echo "  detected: ${detected:+${detected##*/}}${detected:-<none>}"
    echo
    echo "  1) use detected projector"
    echo "  2) enter path manually"
    echo "  3) disable (run text-only)"
    echo "  4) set encoder GPU"
    echo "  Enter) keep current"
    echo
    read -p "Choice: " mm_choice || true

    case "$mm_choice" in
      1)
        if [ -z "$detected" ]; then
          echo "No mmproj found next to this model."
          continue
        fi
        MMPROJ="$detected"
        MMPROJ_DISABLED=0
        [ -z "$MMPROJ_DEVICE" ] && MMPROJ_DEVICE="$(resolve_mmproj_device)"
        ;;
      2)
        read -p "Path to mmproj .gguf: " mm_path || true
        if [ -n "$mm_path" ] && [ -f "$mm_path" ]; then
          MMPROJ="$mm_path"
          MMPROJ_DISABLED=0
          [ -z "$MMPROJ_DEVICE" ] && MMPROJ_DEVICE="$(resolve_mmproj_device)"
        else
          echo "File not found: ${mm_path:-<empty>}"
        fi
        ;;
      3)
        MMPROJ=""
        MMPROJ_DISABLED=1
        MMPROJ_DEVICE=""
        ;;
      4)
        mmproj_select_device
        ;;
      ""|k|K)
        break
        ;;
      *)
        echo "Invalid choice"
        ;;
    esac
  done
  return 0
}

# Interactive step used by the custom pipeline.
setup_mmproj() {
  local detected
  detected="$(find_mmproj_for_model "$SELECTED")"

  if [ -z "$MMPROJ" ] && [ -n "$detected" ] && [ "${MMPROJ_DISABLED:-0}" != "1" ]; then
    MMPROJ="$detected"
    [ -z "$MMPROJ_DEVICE" ] && MMPROJ_DEVICE="$(resolve_mmproj_device)"
  fi

  if [ -n "$MMPROJ" ]; then
    echo
    echo -e "Multimodal projector: \033[35m${MMPROJ##*/}\033[0m  (encoder: ${MMPROJ_DEVICE:-default})"
    read -p "Change mmproj settings? [y/N]: " change_mm || true
    if [[ "$change_mm" =~ ^[Yy]$ ]]; then
      mmproj_menu
    fi
  else
    read -p "Attach a multimodal projector (mmproj)? [y/N]: " want_mm || true
    if [[ "$want_mm" =~ ^[Yy]$ ]]; then
      mmproj_menu
    fi
  fi
  return 0
}

# Hook used by the decision gate [m] action.
edit_mmproj() {
  mmproj_menu
}
