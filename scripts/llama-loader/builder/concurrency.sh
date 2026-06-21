# ============================================================
# BUILDER: Concurrency
# Prompts for NP (parallel sequences) and NGL (GPU layers).
# ============================================================
LAST_NP=$(resolve_np)
echo
read -p "Parallel sequences [--np ${LAST_NP}]: " NP_IN
case "${NP_IN:-$LAST_NP}" in
  a|A|auto)
    NP_MODE="auto"
    NP_VAL="auto"
    NP_ARG="--np auto"
    ;;
  [2-8])
    NP_MODE="manual"
    NP_VAL="${NP_IN:-$LAST_NP}"
    validate_int "$NP_VAL" >/dev/null
    NP_ARG="--np $NP_VAL"
    ;;
  *)
    NP_MODE="manual"
    NP_VAL="${NP_IN:-$LAST_NP}"
    validate_int "$NP_VAL" >/dev/null 2>&1 || NP_VAL="$LAST_NP"
    NP_ARG="--np $NP_VAL"
    ;;
esac

# auto is runtime-only — resolve_np returns fallback integer on next load

LAST_NGL=$(resolve_default "ngl" "60")
echo
read -p "GPU layers [-ngl ${LAST_NGL}]: " NGL_IN
NGL=${NGL_IN:-$LAST_NGL}
