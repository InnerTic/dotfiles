# ============================================================
# BUILDER: GPU
# Dual-GPU aware execution mode selector
#
# NOTE:
# Modes represent INTENT CLASSES, not performance presets.
# ============================================================

echo
echo "GPU modes (intent-based):"
echo
echo "  1) RTX 3060 only (fast compute / lowest latency)"
echo "  2) P40 only (max VRAM / largest single-GPU fit)"
echo
echo "  3) Capacity-balanced dual (6GB + 6GB target fit)"
echo "     -> model is distributed evenly across GPUs"
echo "     -> prioritizes 'fits at all' over speed"
echo
echo "  4) P40-heavy dual (10/90 split)"
echo "     -> VRAM dominant workload offload"
echo
echo "  5) 3060-heavy dual (90/10 split)"
echo "     -> compute front-loading / experimental latency shift"
echo
echo "  6) Manual split (expert mode)"
echo "     -> fully user-defined tensor distribution"
echo

LAST_GPU_MODE=$(resolve_default "gpu_mode" "3")

read -p "Select GPU mode [1-6, default: $LAST_GPU_MODE]: " GPU_MODE
GPU_MODE=${GPU_MODE:-$LAST_GPU_MODE}

GPU_ARG="--main-gpu 0"
TENSOR_SPLIT=""

case "$GPU_MODE" in

  # ------------------------------------------------------------
  # 1. Single GPU (3060)
  # ------------------------------------------------------------
  1)
    GPU_ARG="--main-gpu 0"
    TENSOR_SPLIT=""
    GPU_MODE_LABEL="RTX_3060_FAST_PATH"
    ;;

  # ------------------------------------------------------------
  # 2. Single GPU (P40)
  # ------------------------------------------------------------
  2)
    GPU_ARG="--main-gpu 1"
    TENSOR_SPLIT=""
    GPU_MODE_LABEL="P40_VRAM_MAX"
    ;;

  # ------------------------------------------------------------
  # 3. Capacity-balanced dual (IMPORTANT SPECIAL CASE)
  # ------------------------------------------------------------
  3)
    GPU_ARG="--main-gpu 0"
    TENSOR_SPLIT="50,50"
    GPU_MODE_LABEL="DUAL_CAPACITY_BALANCED"
    ;;

  # ------------------------------------------------------------
  # 4. P40-heavy dual
  # ------------------------------------------------------------
  4)
    GPU_ARG="--main-gpu 0"
    TENSOR_SPLIT="10,90"
    GPU_MODE_LABEL="DUAL_P40_HEAVY"
    ;;

  # ------------------------------------------------------------
  # 5. 3060-heavy dual
  # ------------------------------------------------------------
  5)
    GPU_ARG="--main-gpu 0"
    TENSOR_SPLIT="90,10"
    GPU_MODE_LABEL="DUAL_3060_HEAVY"
    ;;

  # ------------------------------------------------------------
  # 6. Manual expert split
  # ------------------------------------------------------------
  6)
    echo "Enter custom tensor split (e.g. 25,75):"
    read -p "> " TENSOR_SPLIT
    GPU_ARG="--main-gpu 0"
    GPU_MODE_LABEL="DUAL_MANUAL"
    ;;

  # ------------------------------------------------------------
  # fallback
  # ------------------------------------------------------------
  *)
    GPU_ARG="--main-gpu 0"
    TENSOR_SPLIT="50,50"
    GPU_MODE_LABEL="DUAL_CAPACITY_BALANCED_DEFAULT"
    ;;
esac
