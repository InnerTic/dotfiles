# ============================================================
# BUILDER: Concurrency
# Prompts for NP (parallel sequences) and NGL (GPU layers).
# ============================================================
LAST_NP=$(resolve_default "np" "1")
echo
read -p "Parallel sequences [-np ${LAST_NP}]: " NP_IN
case "${NP_IN:-$LAST_NP}" in
  a|A|auto) NP_ARG="-np auto" ;;
  [2-8]) NP_ARG="-np $NP_IN" ;;
  *) NP_ARG="-np $LAST_NP" ;;
esac

LAST_NGL=$(resolve_default "ngl" "60")
echo
read -p "GPU layers [-ngl ${LAST_NGL}]: " NGL_IN
NGL=${NGL_IN:-$LAST_NGL}
