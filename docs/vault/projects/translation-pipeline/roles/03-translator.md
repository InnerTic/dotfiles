# Translator

**Port:** 8083 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

Literal Japanese→English translation using:
- Approved glossary — must use these terms
- Candidate glossary — can use but flags as new
- Style bible — honorific rules, quote style, capitalization
- Difficulty assessment — Low/Medium/High with reasons (actionable for reviewer)

The Translator is deliberately **constrained** — no creative license. Literal meaning first, naturalness second.

## Current Model

`Qwen3.6-27B-Q4_K_M.gguf` — 16G, 27B params (dense)

**Path:** `/mnt/data/model_storage/Qwen3.6-27B-Q4_K_M.gguf`

**Why this model:**
- **27B params** — good balance of comprehension vs VRAM on P40
- **Qwen3.6** — strong multilingual capabilities, handles Japanese syntax well
- **Q4_K_M** — standard quality quantization, fits with 4096 context
- **Dense architecture** — more reliable per-token than MoE for constrained tasks

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Qwen3.5-21B-Claude-4.6-Opus-Deckard-Heretic-Uncensored-Thinking.i1-Q5_K_M.gguf` | 14G | 21B params, Q5. Thinking model — may over-analyze instead of translating literally. |
| `OpenAI-20B-NEO-Uncensored2-Q5_1.gguf` | 16G | 20B params. Uncensored — may choose inappropriate translations for NSFW content. |
| `gpt-oss-20b-hermes.Q5_K_M.gguf` | 16G | 20B general. Less specialized for translation. |
| `Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE.gguf` | 16G | Vision model — adds image understanding but MoE ~4B active. Weaker per-token. |

**Note on Translator alternatives:** The translator role is the hardest to replace. Smaller models (<20B) consistently miss glossary terms and produce less accurate syntax. If swapping, prefer dense architectures over MoE.
