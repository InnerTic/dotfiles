# Verifier

**Port:** 8085 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

Sentence-by-sentence comparison of original vs edited translation. Uses briefer's Ambiguity Anchors, glossary, character database, and style bible.

Reports with severity (HIGH/MEDIUM/LOW):
- Omissions from original
- Additions not in original
- Name errors (same character, different name)
- Honorific drift (preserved vs dropped)
- Tense inconsistency
- Terminology mismatch with glossary
- Continuity violations (character state from DB)
- Ambiguity Anchor resolution (did the translator handle ambiguous pronouns correctly?)

**Must NOT rewrite any text.** Produces issue report only.

## Current Model

`DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` — 17G, 24B params (dense)

**Path:** `/home/ken/Downloads/llm_models/DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf`

**Why this model:**
- **"Deep Thinker"** — the verifier role requires careful reasoning, which benefits from thinking-style models
- **D_AU fine-tune** — "Detailed, Accurate, Useful" training aligns perfectly with the verifier's requirements
- **24B params** — good quality without consuming the full P40
- **q5_k_m** — higher quantization than most other big models (Q5 vs Q4), better precision for comparison
- **17G size** — leaves ~7GB VRAM headroom on P40 for KV cache at 4096 context

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Qwen3.5-21B-Claude-4.6-Opus-Deckard-Heretic-Uncensored-Thinking.i1-Q5_K_M.gguf` | 14G | 21B. Also a thinking model, smaller, Q5. Less param capacity but frees VRAM. |
| `LLMBG-ToolUse-27B-v1.0.i1-Q4_K_M.gguf` | 16G | 27B tool fine-tune. Might format reports too rigidly. |
| `L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf` | 17G | MoE 25B. Dark-themed fine-tune — may inject negativity into issue reports. |

**Verifier is the most critical quality gate.** Don't swap to a weaker model unless the current one is unavailable. The "Deep Thinker" training is specifically suited for this.
