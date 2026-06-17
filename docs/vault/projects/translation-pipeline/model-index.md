# Model Index & Evaluation

Complete inventory of all available LLMs with architecture notes, role suitability, and tradeoffs.

## Quick Picks by Role

| Role | Best Model | Runner-Up |
|------|-----------|-----------|
| **Briefer** (extraction) | `PromptEnhancer-32B` | `gemma-4-aplex-compact` |
| **Translator** (multilingual) | `Qwen3.6-27B` | `Qwen3.5-21B-thinking` |
| **Editor** (3060, ≤7B active) | `Floppa-12B` | `gemma-4-aplex-compact` |
| **Verifier** (analysis) | `DS4X8R1L3.1-Dp-Thnkr-24B` | `Qwen3.5-21B-thinking` |
| **Consistency** (comparison) | `Qwen2.5-Coder-32B-Rombo-TIES` | `Qwen2.5-Coder-14B-Q8` |
| **Glossary/Continuity** (structured) | `gemma-4-26B-APEX-Compact` | `Floppa-12B` |

---

## GPU 0 (RTX 3060 12GB)

Models that fit the 3060 — either small dense or MoE with few active experts.

### Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 6.8G |
| **Arch** | 12B dense, i1-Q4_K_M |
| **VRAM** | ~7GB (fits 3060 with 4096 ctx) |
| **Base** | Gemma-3 |

**Evaluation: ★★★★☆** — Best dense model for 3060 by a wide margin. Gemma-3 base is solid, uncensored means no refusals. Imatrix quantization preserves quality. Only 12B but that's the limit for the 3060 with dense models. **Use for:** editor, optionally glossary/continuity if you want better state reasoning.

### gemma-2-2b-it-Q6_K_L.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 2.2G |
| **Arch** | 2B dense, Q6_K_L |
| **VRAM** | ~2.5GB |

**Evaluation: ★★☆☆☆** — Too small for any pipeline role. 2B params cannot reliably extract or reason about content. Keep as curiosity or potential classifier/summarizer for non-critical tasks.

### gemma-4-26B-A4B-APEX-Compact.gguf (3060-compatible via MoE)

See P40 section below for full spec. **Also fits 3060** because MoE only activates ~7B params per token despite 14G disk size. Marginally fits — less headroom than Floppa but more capable when it works.

---

## GPU 1 (Tesla P40 24GB)

### PromptEnhancer-32B.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 19G |
| **Arch** | 32B dense, i1-Q4_K_M |
| **VRAM** | ~20GB (fits P40 with ~4GB headroom) |

**Evaluation: ★★★★★** — Specialized for extraction and structured output. 32B dense gives it the best comprehension of any model in the inventory. The "prompt enhancer" training is nearly a perfect match for the **briefer** role (extract characters, locations, relationships, ambiguity). The Q4_K_M is the sweet spot for quality/size on the P40. **Only downside:** 2048 context is tight for long chunks + character DB.

### Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 19G |
| **Arch** | 32B dense, i1-Q4_K_M, Rombo-TIES merge |
| **VRAM** | ~20GB |

**Evaluation: ★★★★☆** — Excellent for comparison/diff tasks. The Qwen2.5-Coder base is unusually good at structured text analysis (exact matching, diffing, pattern recognition). Rombo-TIES merge adds instruction-following without losing coder precision. Abliterated = no refusals. **Best for:** consistency checker (diff across chunks). **Also good for:** any role needing exact text comparison.

### DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 17G |
| **Arch** | 24B dense, q5_k_m |
| **VRAM** | ~18GB (7GB headroom on P40) |

**Evaluation: ★★★★★** — The verifier's model and for good reason. "Deep Thinker" reasoning capability is ideal for sentence-by-sentence comparison. D_AU (Detailed, Accurate, Useful) training directly targets the quality needed for issue reporting. Q5 quantization is higher than most (better quality per param). 24B is enough parameters. **Best for:** verifier — the only model trained specifically for this kind of careful analysis. **Runner up for:** consistency checker.

### Qwen3.6-27B-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | 27B dense, Q4_K_M |
| **VRAM** | ~17GB (7GB headroom on P40) |

**Evaluation: ★★★★☆** — Current-gen Qwen, strong multilingual support. 27B dense is a good param count for the P40. The 8GB VRAM headroom is a real advantage — allows larger context (up to 8192 with no-mmap). **Best for:** translator (multilingual strength). **Also good for:** any role where you want dense 27B over MoE variants.

**⚠ Script path mismatch:** The scripts reference `~/Downloads/llm_models/Qwen3.6-27B-Q4_K_M.gguf` but the actual model is at `/mnt/data/model_storage/Qwen3.6-27B-Q4_K_M.gguf`. The scripts will fail with "model not found."

### Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 16G |
| **Arch** | MoE 3B active (30B total), MXFP4 |
| **VRAM** | ~4GB active (fits anywhere) |

**Evaluation: ★★☆☆☆** — Vision model with aggressive MXFP4 quantization. Only 3B active params — significantly less capable per-token than any dense model. Only useful if you need multimodal (image+text) understanding. For text-only translation pipeline roles, every dense model above outperforms it. **Avoid for text-only roles.**

### gemma-4-26B-A4B-APEX-Compact.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 14G |
| **Arch** | MoE 4/26 active (~7B), Q4_K_M |
| **VRAM** | ~8GB active (fits 3060 or P40) |

**Evaluation: ★★★★☆** — The swiss army knife. Fits **both** GPUs because active params are only ~7B despite 14G disk. "Compact" instruct variant avoids creative drift — good for structured extraction tasks. **Best for:** glossary updater, continuity updater (current role). **Runner up for:** editor (swap with Floppa if you need more capability). **⚠ Script path mismatch:** Scripts reference `~/Downloads/llm_models/` but the model is at `/mnt/data/model_storage/`.

### gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 20G |
| **Arch** | MoE 4/26 active (~7B), experimental fine-tune |
| **VRAM** | ~8GB active |

**Evaluation: ★★★☆☆** — Same MoE architecture but takes 6G more disk for the same ~7B active params. "Heretic" fine-tune may be better for creative writing but that's the opposite of what constrained pipeline roles need. "APEX-I-Quality" is experimental — quality is uncertain. **Not recommended over APEX-Compact** unless you've tested it and found it better for a specific role.

### gemma-4-26B-A4B-it-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | MoE 4/26 active (~7B), stock instruct |
| **VRAM** | ~8GB active |

**Evaluation: ★★★☆☆** — Stock Gemma-4 instruct. No special fine-tuning. Functions but every variant below is a better choice for specific use cases. **Baseline only.**

### gemma-4-26B-A4B-it-uncensored-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | MoE 4/26 active (~7B), stock uncensored |
| **VRAM** | ~8GB active |

**Evaluation: ★★★☆☆** — Same as stock but uncensored. Only useful if the stock model refuses content. Identical quality otherwise.

### gemma-4-26B-A4B-it-Claude-Opus-Distill.q4_k_m.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | MoE 4/26 active (~7B), Claude Opus distill |
| **VRAM** | ~8GB active |

**Evaluation: ★★★★☆** — Distilled from Claude Opus outputs, which means it may produce higher quality structured responses than the stock instruct. Potentially the best Gemma-4 variant for structured roles (glossary, continuity) if the distill quality carries over. **Worth testing** against APEX-Compact.

### supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | MoE 4/26 active (~7B), speed-optimized |
| **VRAM** | ~8GB active |

**Evaluation: ★★☆☆☆** — "Fast" variants trade quality for speed. In a pipeline that's I/O-bound (loading/unloading models), inference speed isn't the bottleneck. Lower quality per token with no meaningful benefit. **Not recommended.**

### L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 17G |
| **Arch** | MoE 4/8 active (~8B), Q5_K_M |
| **VRAM** | ~9GB active |

**Evaluation: ★★★☆☆** — MoE with ~8B active, 25B total. Q5 quantization is good. D_AU training (same as verifier) suggests decent analysis capability. "Dark Planet" theme may inject mood/tone into output — could be neutral or problematic depending on the role. **Could test** as consistency checker alternative but the theme risk is real.

### Llama3.2-24B-A3B-II-Dark-Champion-...-Heretic-Abliterated-Uncensored.i1-Q6_K.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 14G |
| **Arch** | MoE 3B active (24B total), Q6_K |
| **VRAM** | ~4GB active |

**Evaluation: ★★☆☆☆** — Only 3B active params despite the long name and 14G file. Q6_K quantization is very good but the active capacity is simply too low for pipeline tasks. Many fine-tune merges piled on (Dark Champion + Heretic + Abliterated + Uncensored) make this an unpredictable blend. **Not recommended for translation pipeline.**

### Llama-3.2-4X3B-MOE-Ultra-Instruct-10B-D_AU-Q8_0.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 9.9G |
| **Arch** | MoE 4x3B active (~4B), Q8_0 |
| **VRAM** | ~5GB active |

**Evaluation: ★★★☆☆** — Q8_0 means near-lossless quantization quality, and "Ultra Instruct" focuses on instruction following. ~4B active is still quite small. Could serve as a lightweight fallback for consistency checker if the P40 is busy, but at 4B active it will miss subtle drift. **Lightweight fallback only.**

### Qwen2.5-Coder-14B-Instruct-Uncensored.Q8_0.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` + `/mnt/data/model_storage/` (both) |
| **Size** | 15G |
| **Arch** | 14B dense, Q8_0 |
| **VRAM** | ~16GB |

**Evaluation: ★★★★☆** — 14B dense at Q8_0 is a surprisingly strong combination. Q8 is near-lossless, meaning this 14B model may match a Q4 20B model in output quality for comparison tasks. The coder base is good for structured analysis. Fits P40 with ~8GB headroom. **Best as:** lightweight consistency checker (swap with 32B coder when faster response matters). **Worth testing** as an alternative to the 32B coder — it's 4G smaller and inference is significantly faster.

### Qwen3.5-21B-Claude-4.6-Opus-Deckard-Heretic-Uncensored-Thinking.i1-Q5_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 14G |
| **Arch** | 21B dense, Q5_K_M, thinking model |
| **VRAM** | ~15GB (9GB headroom on P40) |

**Evaluation: ★★★★☆** — A thinking (chain-of-thought) model at 21B with Q5 quantization. Claude Opus distill suggests training on high-quality reasoning traces. The thinking style is great for the verifier role (sentence-by-sentence comparison requires reasoning). 9GB VRAM headroom on P40 allows large context. **Best as:** verifier alternative (more headroom than current verifier model). **Also good for:** translator alternative (reasoning before translating).

### LLMBG-ToolUse-27B-v1.0.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | 27B dense, tool-use fine-tune |
| **VRAM** | ~17GB (7GB headroom) |

**Evaluation: ★★★☆☆** — 27B dense with tool-use training. Good param count but the specialization for function calling means it may produce overly structured output for narrative tasks. Could work well for glossary/continuity (structured markdown output). May be too rigid for translator or editor. **Best for:** roles requiring strictly formatted output.

### OpenAI-20B-NEO-Uncensored2-Q5_1.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | 20B dense, Q5_1 (5-bit) |
| **VRAM** | ~17GB |

**Evaluation: ★★☆☆☆** — Despite the name, has nothing to do with OpenAI. "NEO" seems to be a general instruct fine-tune but provenance is unclear. Q5_1 quantization is decent. No specialized training advantage. **Any other 20B+ model is a better choice.** Only use if nothing else is available.

### gpt-oss-20b-hermes.Q5_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` + `/mnt/data/model_storage/` (both) |
| **Size** | 16G |
| **Arch** | 20B dense, Hermes fine-tune, Q5_K_M |
| **VRAM** | ~17GB |

**Evaluation: ★★★☆☆** — Hermes fine-tune is well-regarded for instruction following. 20B at Q5_K_M is decent quality. Distributed (model_storage + ssd = "free" in terms of storage). **Solid fallback** for any P40 role. Not specialized for anything but competent at everything. **Use as:** general-purpose backup when the preferred model isn't available.

---

## Evaluation Summary

| Tier | Models | Best For |
|------|--------|----------|
| **★★★★★** Excellent | `PromptEnhancer-32B`, `DS-Dp-Thnkr-24B` | Extraction, analysis (specialized fits) |
| **★★★★☆** Very Good | `Qwen3.6-27B`, `Qwen2.5-Coder-32B`, `gemma-4-APEX-Compact`, `Floppa-12B`, `Qwen3.5-21B-Thinking`, `Qwen2.5-Coder-14B-Q8` | Current pipeline roles |
| **★★★☆☆** Decent | `gemma-4-stock-*`, `L3-4X8B-MOE`, `gpt-oss-20b-hermes`, `LLMBG-ToolUse-27B`, `Llama-4X3B-MOE` | Fallbacks, testing |
| **★★☆☆☆** Weak | `Qwen3-VL-MoE`, `Llama3.2-24B-A3B`, `supergemma-fast`, `OpenAI-20B-NEO` | Only if nothing else fits |
| **★☆☆☆☆** Not useful | `gemma-2-2b-it` | Too small for pipeline |

## Path Notes

Several scripts reference incorrect model paths. Current state:

| Script | References | Actual Location |
|--------|-----------|-----------------|
| `glossary-update.sh` | `~/Downloads/llm_models/gemma-4-26B-A4B-APEX-Compact.gguf` | `/mnt/data/model_storage/` |
| `continuity-update.sh` | Same | `/mnt/data/model_storage/` |
| `pipe.sh` (MODEL_GEMMA) | Same | `/mnt/data/model_storage/` |
| `translate.sh` | `~/Downloads/llm_models/Qwen3.6-27B-Q4_K_M.gguf` | `/mnt/data/model_storage/` |
| `pipe.sh` (MODEL_TRANSLATOR) | Same | `/mnt/data/model_storage/` |

The symlink `~/Downloads/llm_models/llm_models` → ssd doesn't cover model_storage. Fix: either move models or update script paths to `../../model_storage/` or absolute `/mnt/data/model_storage/`.
