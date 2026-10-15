#!/usr/bin/env bash
# ============================================================
# BUILDER: Extra Arguments
# Interactive editor for extra llama.cpp CLI flags.
# Stores args as a structured array (EXTRA_ARGS), not a string.
# ============================================================

# Known arguments with descriptions (format: "flag|description|needs_value")
KNOWN_ARGS=(
  "--jinja|Enable Jinja template engine|0"
  "--no-jinja|Disable Jinja template engine|0"
  "--flash-attn|Enable flash attention|0"
  "--no-flash-attn|Disable flash attention|0"
  "--no-mmap|Disable memory-mapped file loading|0"
  "--mlock|Lock model in RAM (no swap)|0"
  "--no-kv-offload|Keep KV cache on CPU|0"
  "--cache-type-k|KV cache quantization for K (q4_0, q8_0, f16)|1"
  "--cache-type-v|KV cache quantization for V (q4_0, q8_0, f16)|1"
  "--cont-batching|Enable continuous batching|0"
  "--no-cont-batching|Disable continuous batching|0"
  "--metrics|Enable Prometheus metrics endpoint|0"
  "--no-metrics|Disable Prometheus metrics endpoint|0"
  "--slot-id|Target a specific slot for /completion|1"
  "--lora|Apply LoRA adapter (path:name:scale)|1"
  "--lora-scaled|Apply LoRA with explicit scaling|1"
  "--log-disable|Disable logging to stdout|0"
  "--log-format|Log format (text, json)|1"
  "--reasoning-budget|Reasoning token budget (auto, 0-N)|1"
  "--numa|NUMA optimization (disabled, distribute, numactl)|1"
  "--no-warmup|Skip warmup run|0"
  "--override-kv|Override model metadata key|1"
)

show_extra_args_menu() {
  echo
  echo "EXTRA LLAMA.CPP ARGUMENTS"
  echo "────────────────────────────────"

  if [[ ${#EXTRA_ARGS[@]} -eq 0 ]]; then
    echo "  [none]"
  else
    local i=1
    while [[ $i -lt ${#EXTRA_ARGS[@]} ]]; do
      local flag="${EXTRA_ARGS[$i]}"
      # Find description from KNOWN_ARGS
      local desc=""
      for known in "${KNOWN_ARGS[@]}"; do
        IFS='|' read -r kflag kdesc kneeds <<< "$known"
        if [[ "$kflag" == "$flag" ]]; then
          desc="$kdesc"
          break
        fi
      done
      if [[ $((i+1)) -lt ${#EXTRA_ARGS[@]} ]] && [[ "${EXTRA_ARGS[$((i+1))}" != --* ]]; then
        # Next element is a value (not a flag)
        printf "  [%d] %s %s" "$((i/2+1))" "$flag" "${EXTRA_ARGS[$((i+1))]}"
        i=$((i+2))
      else
        printf "  [%d] %s" "$((i/2+1))" "$flag"
        i=$((i+2))
      fi
      if [[ -n "$desc" ]]; then
        printf "  (%s)" "$desc"
      fi
      echo
    done
  fi

  echo
  echo "  [a] add argument"
  echo "  [r] remove argument"
  echo "  [c] clear all"
  echo "  [Enter] done"
}

add_extra_arg() {
  echo
  echo "Available arguments:"
  local idx=1
  for known in "${KNOWN_ARGS[@]}"; do
    IFS='|' read -r flag desc needs_val <<< "$known"
    local val_hint=""
    if [[ "$needs_val" == "1" ]]; then
      val_hint=" (requires value)"
    fi
    printf "  %2d) %s%s — %s\n" "$idx" "$flag" "$val_hint" "$desc"
    idx=$((idx+1))
  done

  read -p "Select argument [1-${#KNOWN_ARGS[@]}]: " choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#KNOWN_ARGS[@]} ]]; then
    echo "Invalid selection"
    return
  fi

  local selected="${KNOWN_ARGS[$((choice-1))]}"
  IFS='|' read -r flag desc needs_val <<< "$selected"

  # Check if flag already present
  for ((i=0; i<${#EXTRA_ARGS[@]}; i++)); do
    if [[ "${EXTRA_ARGS[$i]}" == "$flag" ]]; then
      echo "Flag already present: $flag"
      return
    fi
  done

  if [[ "$needs_val" == "1" ]]; then
    read -p "Value for $flag: " val
    if [[ -n "$val" ]]; then
      EXTRA_ARGS+=("$flag" "$val")
      echo "Added: $flag $val"
    else
      echo "No value provided — skipped"
    fi
  else
    EXTRA_ARGS+=("$flag")
    echo "Added: $flag"
  fi
}

remove_extra_arg() {
  if [[ ${#EXTRA_ARGS[@]} -eq 0 ]]; then
    echo "No arguments to remove"
    return
  fi

  show_extra_args_menu
  read -p "Remove which number? " choice

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]]; then
    echo "Invalid selection"
    return
  fi

  local target_idx=$(( (choice - 1) * 2 ))
  if [[ $target_idx -ge ${#EXTRA_ARGS[@]} ]]; then
    echo "Invalid selection"
    return
  fi

  local flag="${EXTRA_ARGS[$target_idx]}"

  # Check if this flag takes a value
  local needs_val=0
  for known in "${KNOWN_ARGS[@]}"; do
    IFS='|' read -r kflag kdesc kneeds <<< "$known"
    if [[ "$kflag" == "$flag" ]]; then
      needs_val="$kneeds"
      break
    fi
  done

  # Remove the flag (and value if applicable)
  local new_args=()
  local skip_next=0
  for ((i=0; i<${#EXTRA_ARGS[@]}; i++)); do
    if [[ $skip_next -eq 1 ]]; then
      skip_next=0
      continue
    fi
    if [[ $i -eq $target_idx ]]; then
      if [[ "$needs_val" == "1" && $((i+1)) -lt ${#EXTRA_ARGS[@]} ]]; then
        skip_next=1  # also skip the value
      fi
      continue
    fi
    new_args+=("${EXTRA_ARGS[$i]}")
  done

  EXTRA_ARGS=("${new_args[@]}")
  echo "Removed: $flag"
}

validate_extra_args() {
  if [[ ${#EXTRA_ARGS[@]} -eq 0 ]]; then
    return 0
  fi

  # Validate against known args (warn on unknown)
  local unknown=()
  local i=0
  while [[ $i -lt ${#EXTRA_ARGS[@]} ]]; do
    local flag="${EXTRA_ARGS[$i]}"
    if [[ "$flag" == --* ]]; then
      local found=0
      for known in "${KNOWN_ARGS[@]}"; do
        IFS='|' read -r kflag kdesc kneeds <<< "$known"
        if [[ "$kflag" == "$flag" ]]; then
          found=1
          # If flag requires value, check next element
          if [[ "$kneeds" == "1" ]]; then
            if [[ $((i+1)) -ge ${#EXTRA_ARGS[@]} ]] || [[ "${EXTRA_ARGS[$((i+1))]}" == --* ]]; then
              unknown+=("$flag (missing value)")
            fi
          fi
          break
        fi
      done
      if [[ $found -eq 0 ]]; then
        unknown+=("$flag")
      fi
    fi
    i=$((i+1))
  done

  if [[ ${#unknown[@]} -gt 0 ]]; then
    echo
    echo "EXTRA ARGUMENT VALIDATION"
    echo "──────────────────────────"
    for u in "${unknown[@]}"; do
      echo "  $u  ✗ unknown"
    done
    echo
    read -p "Unknown arguments detected. Continue anyway? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  return 0
}

# Main loop
edit_extra_args() {
  while true; do
    show_extra_args_menu
    read -p "Action: " action

    case "${action:-}" in
      a|A) add_extra_arg ;;
      r|R) remove_extra_arg ;;
      c|C) EXTRA_ARGS=(); echo "Cleared all extra arguments" ;;
      "") break ;;
      *) echo "Unknown action" ;;
    esac
  done
}
