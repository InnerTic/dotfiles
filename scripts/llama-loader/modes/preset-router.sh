#!/usr/bin/env bash
# ============================================================
# MODE: Preset Router
# Lists immutable presets, sources the selected one, launches.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

list_models
select_model

PRESETS=()
for f in "$SCRIPT_DIR/presets/"*.sh; do
  [ -f "$f" ] && PRESETS+=("$f")
done

if [ ${#PRESETS[@]} -eq 0 ]; then
  echo "No presets found"
  exit 1
fi

echo
echo "Available presets:"
for i in "${!PRESETS[@]}"; do
  name=$(basename "${PRESETS[$i]}" .sh)
  desc=$(head -5 "${PRESETS[$i]}" | grep "^#" | tail -1 | sed 's/^# *//')
  printf "  %d) %s\n" $((i+1)) "$desc"
done

read -p "Select preset [1-${#PRESETS[@]}]: " pchoice
if ! [[ "$pchoice" =~ ^[0-9]+$ ]] || [ "$pchoice" -lt 1 ] || [ "$pchoice" -gt "${#PRESETS[@]}" ]; then
  echo "Invalid selection"
  exit 1
fi

assert_clean_state
source "${PRESETS[$((pchoice-1))]}"

[ -z "$CTX_SIZE" ] && CTX_SIZE=16384
[ -z "$TENSOR_SPLIT" ] && TENSOR_SPLIT="20,80"
[ -z "$NGL" ] && NGL=60
[ -z "${NP_VAL:-}" ] && NP_VAL=2
NP_ARG="--np $NP_VAL"
NP_MODE=manual
[ -z "$PORT" ] && PORT=8080
GPU_ARG="--main-gpu 0"

show_snapshot "PRESET"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
