# Editor

**Port:** 8084 | **GPU:** 3060 (CUDA0) | **Context:** 4096

## Role

Takes the literal translation and improves readability / natural English prose. Must preserve:
- All names, terms, honorifics
- Original meaning
- Content (no omissions or additions)

Outputs edited text + Edit Log:
- Sentence compressed? yes/no
- Tone shift? none/mild/moderate (must justify)
- Reordering? yes/no

## Current Model

`Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` — 6.8G, 12B params (dense)

**Path:** `/home/ken/Downloads/llm_models/Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf`

**Why this model:**
- **Only 12B dense** — only option that fits 3060 with good quality
- **Gemma3 base** — strong instruction following, which matters for the constrained editing task
- **Uncensored** — won't refuse or rephrase controversial content
- **No `--device CUDA0` flag** — runs on default GPU (3060) since it's the only GPU when this starts

## Alternatives (3060-friendly)

The 3060's 12GB VRAM severely limits options. The only other model that fits:

| Model | Size | Tradeoff |
|-------|------|----------|
| `gemma-2-2b-it-Q6_K_L.gguf` | 2.2G | 2B params — far too weak for editing |
| `gemma-4-26B-A4B-APEX-Compact.gguf` | 14G | MoE ~7B active, but swaps this from glossary role. Could alternate. |

**If the 3060 is insufficient:** Could run editor on P40 while translator/briefer are idle, but this breaks the pipeline's sequential flow. The 3060 slot is the pipeline's bottleneck.
