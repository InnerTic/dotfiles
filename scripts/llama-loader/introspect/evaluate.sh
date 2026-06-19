# ============================================================
# INTROSPECT: Feasibility Evaluator
# Purely analytical — no execution, no modification.
# Evaluates resolved config and returns assessment.
# ============================================================

# Estimate VRAM pressure
vram_level="low"
feasibility="OK"
notes=""

# Context heuristic
if [ "$CTX_SIZE" -ge 131072 ]; then
  vram_level="extreme"
  notes+="  - KV cache at ${CTX_SIZE} will consume significant VRAM"
elif [ "$CTX_SIZE" -ge 65536 ]; then
  vram_level="high"
  notes+="  - KV cache at ${CTX_SIZE} may stress VRAM"
elif [ "$CTX_SIZE" -ge 32768 ]; then
  vram_level="medium"
fi

# NGL heuristic
if [ "$NGL" -ge 80 ]; then
  notes+="  - High NGL (${NGL}) may cause OOM on RTX 3060"
  [ "$vram_level" = "low" ] && vram_level="medium"
fi

# NP heuristic
if [[ "${NP_VAL:-0}" == "auto" ]]; then
  notes+="  - Auto concurrency — dynamic VRAM allocation"
elif [ "${NP_VAL:-0}" -ge 4 ] 2>/dev/null; then
  notes+="  - NP >= 4 increases parallel VRAM pressure"
fi

# Dual GPU note
if [ -n "$TENSOR_SPLIT" ]; then
  notes+="  - Dual GPU active: ${TENSOR_SPLIT} split"
fi

# Determine feasibility
if [ "$vram_level" = "extreme" ]; then
  feasibility="WARN"
elif [ "$vram_level" = "high" ] && [ "$NGL" -ge 99 ]; then
  feasibility="WARN"
fi

echo
echo "INTROSPECTION:"
echo "  FEASIBILITY: $feasibility"
echo "  VRAM: $vram_level"
[ -n "$notes" ] && echo "$notes"
