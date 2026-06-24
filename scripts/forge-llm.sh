#!/bin/bash
# llsd — Dedicated Forge Prompt Enhancer model loader
# Fully independent from llama-loader. Own state, own config, port 8081.
set -e

C="\033[1;36m" N="\033[0m" G="\033[32m" Y="\033[33m" R="\033[31m"

STATE_DIR="$HOME/.config/forge-llm"
STATE_FILE="$STATE_DIR/state.json"
MODEL_DIRS=("$HOME/Downloads/llm_models" "/mnt/data/model_storage")

mkdir -p "$STATE_DIR"

# --- helpers ---
get_state() { grep -m1 "\"$1\":" "$STATE_FILE" 2>/dev/null | sed 's/.*: *"\(.*\)".*/\1/'; }
set_state() {
  local tmp
  if [ -f "$STATE_FILE" ]; then
    tmp=$(mktemp)
    sed "s/\"$1\": *\"[^\"]*\"/\"$1\": \"$2\"/" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
  else
    echo "{\"$1\": \"$2\", \"port\": \"8081\", \"ctx\": \"4096\", \"ngl\": \"60\", \"gpu\": \"0\"}" > "$STATE_FILE"
  fi
}

# --- discover models (exclude mmproj) ---
ALL=""
for DIR in "${MODEL_DIRS[@]}"; do
  [ ! -d "$DIR" ] && continue
  ALL+=$(find "$DIR" -maxdepth 1 -name '*.gguf' ! -name 'mmproj*' -printf '%f\t%s\n' 2>/dev/null)
  ALL+=$'\n'
done
ALL=$(echo "$ALL" | grep -v '^$' | sort -t$'\t' -k1 -u)
if [ -z "$ALL" ]; then echo "No GGUF models found"; exit 1; fi
IFS=$'\n' read -d '' -r -a MODELS <<< "$ALL" || true

# --- menu ---
LAST=$(get_state "last_model")
LAST_GPU=$(get_state "gpu" || echo "0")
echo -e "${C}llsd — Forge Prompt Enhancer loader (port 8081)${N}"
echo
for i in "${!MODELS[@]}"; do
  n=${MODELS[$i]%%$'\t'*}
  s=${MODELS[$i]#*$'\t'}
  mark=""
  [ "$n" = "$LAST" ] && mark=" ${Y}(last)${N}"
  echo -e "  $((i+1))) $n ($(( s / 1024 / 1024 ))MB)$mark"
done
echo
echo -e "  ${R}g)${N} Change GPU (current: ${Y}GPU $LAST_GPU${N})"
echo
read -p "$(echo -e "${Y}Select${N} [1-${#MODELS[@]} or g]: ")" choice

if [ "$choice" = "g" ]; then
  echo
  echo " 0) RTX 3060 (GPU 0)"
  echo " 1) Tesla P40  (GPU 1)"
  read -p "$(echo -e "${Y}GPU${N} [0/1]: ")" gpu_choice
  GPU="${gpu_choice:-0}"
  set_state "gpu" "$GPU"
  echo "GPU set to $GPU"
  exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#MODELS[@]}" ]; then
  echo "Invalid"; exit 1
fi

BASENAME="${MODELS[$((choice-1))]%%$'\t'*}"
MODEL_PATH=$(find "${MODEL_DIRS[@]}" -name "$BASENAME" -print -quit 2>/dev/null)
set_state "last_model" "$BASENAME"
GPU="${LAST_GPU:-0}"

echo
echo -e "${C}Starting:${N} $BASENAME"
echo -e "${C}GPU:${N}     $GPU"
echo -e "${C}Port:${N}    8081"
echo -e "${C}Ctx:${N}     4096"
echo

LLAMA_BIN="/mnt/workspace/llama.cpp/build/bin"
export LD_LIBRARY_PATH="$LLAMA_BIN:$LD_LIBRARY_PATH"
exec "$LLAMA_BIN/llama-server" \
  -m "$MODEL_PATH" \
  --host 0.0.0.0 --port 8081 \
  -c 4096 -ngl 60 -np 1 --main-gpu "$GPU"
