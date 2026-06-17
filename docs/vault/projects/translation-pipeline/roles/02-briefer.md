# Briefer (PromptEnhancer)

**Port:** 8081 | **GPU:** P40 (CUDA1) | **Context:** 2048

## Role

Reads a raw chunk + character database, produces:
- Characters present, locations, relationships
- Prior events referenced
- **Ambiguity Anchors** — who is speaking, pronoun referents, flashback vs present

Briefs the **Verifier only** (step 7), not the Translator. This prevents the Translator from getting creative with extra context.

## Current Model

`PromptEnhancer-32B.i1-Q4_K_M.gguf` — 19G, 32B params (dense)

**Path:** `/home/ken/Downloads/llm_models/PromptEnhancer-32B.i1-Q4_K_M.gguf` (symlink → `/mnt/ssd_storage/ken/Downloads/llm_models/`)

**Why this model:**
- **32B params** — best comprehension of complex character/relationship webs
- **Q4_K_M quantization** — fits P40 24GB with margin (~5GB free for KV cache + overhead)
- **Prompt enhancer training** — specifically tuned for extraction and structured output, almost perfectly matches the briefer role
- **--no-mmap** — loads fully to VRAM, critical for inference speed on P40's slower memory bus

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Qwen3.6-27B-Q4_K_M.gguf` | 16G | 27B params, 5B smaller — maybe slightly less nuance but frees 3GB VRAM. Currently used as translator. |
| `L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf` | 17G | MoE 25B. Dark/moody fine-tune — may inject tone. |
| `LLMBG-ToolUse-27B-v1.0.i1-Q4_K_M.gguf` | 16G | Tool-use fine-tune. Possibly too structured/rigid for narrative extraction. |
| `gpt-oss-20b-hermes.Q5_K_M.gguf` | 16G | 20B params, Q5. Lower comprehension. Only use if 32B isn't available. |
| `Llama3.2-24B-A3B-II-Dark-Champion-INSTRUCT-Heretic-Abliterated-Uncensored.i1-Q6_K.gguf` | 14G | MoE ~3B active. Much less capable per-token despite 14G disk size. |

**Key constraint:** 2048 context is tight — Ambiguity Anchors require the model to remember details from both the chunk and character DB. If context needs to grow, this model stays (32B handles long context well) or swap to `Qwen3.6-27B` with `-c 4096`.
