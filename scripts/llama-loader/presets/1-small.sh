# ============================================================
# PRESET 1: Parser — analytical pipeline roles
# 26B MoE (4B active), fast inference for parser/glossary/briefer
# Doesn't need full 31B dense or long context for analysis
# Trained: 30/70 split fits 20GB model across 3060(12G)+P40(24G)
# ============================================================
MODEL="gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf"
CTX_SIZE=8000
TENSOR_SPLIT="30,70"
NGL=99
NP_VAL=1
PORT=8080
