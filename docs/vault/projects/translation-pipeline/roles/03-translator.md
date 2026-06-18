# Literal Translator

**Port:** 8083 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

Literal Japanese or Chinese → English translation. Nothing else.

**Rules:**
- Literal meaning first
- Preserve names
- Preserve glossary terms
- Preserve honorifics
- Preserve sentence order
- Do NOT embellish
- Do NOT simplify
- Do NOT explain

## Output

- Translation
- Difficulty assessment (Low / Medium / High)
- Reasons

## Current Model

`Qwen3.6-27B-Q4_K_M.gguf` — 16G, 27B params (dense)

**Path:** `/mnt/data/model_storage/Qwen3.6-27B-Q4_K_M.gguf`

**Research wiki:** [`Qwen3.6-27B` →](../../../../../../ai-model-research/individual-models/qwen3.6-27b.md)

**Why this model:**
- **27B params** — good balance of comprehension vs VRAM on P40
- **Qwen3.6** — strong multilingual (Japanese + Chinese), handles syntax well
- **Q4_K_M** — standard quality quantization, fits with 4096 context
- **Dense architecture** — more reliable per-token than MoE for constrained tasks

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `gemma-3-JP-EN-Translator-v1-4B.f16.gguf` | 7.3G | 4B JP→EN specialist. Fast draft engine for low-medium difficulty. |
| `gpt-oss-20b-hermes.Q5_K_M.gguf` | 16G | 20B general. Less specialized for translation. |
| `Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE.gguf` | 16G | Vision model — MoE ~4B active. Weaker per-token. |

> Smaller models (<20B) consistently miss glossary terms and produce less accurate syntax. Prefer dense over MoE for translation.
