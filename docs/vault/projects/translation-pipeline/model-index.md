# Model Index & Evaluation

Complete inventory of all available LLMs with architecture notes, role suitability, and tradeoffs.

## Quick Picks by Role

| Role | Best Model | Runner-Up |
|------|-----------|-----------|
| **Parser** (extraction) | `text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16` | `Floppa-12B` |
| **[[glossary]]** (term discovery) | `gemma-4-26B-APEX-Compact` | `Floppa-12B` |
| **Briefer** (context building) | `DS4X8R1L3.1-Dp-Thnkr-UnC-24B` | `PromptEnhancer-32B` |
| **Translator** (multilingual) | `Qwen3.6-27B` | `gemma-3-JP-EN-Translator-4B` |
| **Editor** (polish) | `gemma-3-it-12B-Q8_0` | `Floppa-12B` |
| **Style Auditor** (style compliance) | `QiMing-Gemma-3-4b` | `Floppa-12B` |
| **Consistency** (comparison) | `Qwen2.5-Coder-32B-Rombo-TIES` | `Qwen2.5-Coder-14B-Q8` |
| **Verifier** (QC) | `PromptEnhancer-32B` | `DS4X8R1L3.1` |
| **Continuity** (state tracking) | `gemma-4-26B-APEX-Compact` | `Floppa-12B` |

> **VRAM note for MoE models:** All expert weights are loaded into VRAM in llama.cpp. File size ≈ VRAM usage. MoE only saves compute (FLOPs), not memory.

---

## GPU 0 (RTX 3060 12GB)

Models that fit the 3060 — file size must be ≤~9GB to leave room for KV cache and CUDA overhead.

### Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 6.8G |
| **Arch** | 12B dense, i1-Q4_K_M |
| **VRAM** | ~7GB (fits 3060 with 4096 ctx) |
| **Base** | Gemma-3 |

**Evaluation: ★★★★☆** — Best dense model for 3060. Gemma-3 base, [[hat-unfiltered]]. **Use for:** editor fallback, [[glossary]]/continuity fallback.

### text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 7.3G |
| **Arch** | 4B dense, f16 |
| **VRAM** | ~7.5GB |

**Evaluation: ★★★★☆** — Specialist for structural extraction. Gemma-3 base provides strong instruction following. Low temp (0.1) keeps output deterministic. **Best for:** parser.

### QiMing-Gemma-3-4b.f16.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 7.3G |
| **Arch** | 4B dense, f16 |
| **VRAM** | ~7.5GB |

**Evaluation: ★★★★☆** — Good rule enforcement & style auditing. 4B Gemma-3 variant. Fits 3060 comfortably. **Best for:** style auditor (current role).

### mistral-7b-instruct-v0.2.Q8_0.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 7.2G |
| **Arch** | 7B dense, Q8_0 |
| **VRAM** | ~7.5GB |

**Evaluation: ★★★☆☆** — Solid [[hat-assistant]] 7B. Useful as editor fallback or light tasks. Not specialized for translation pipeline.

### gemma-3-JP-EN-Translator-v1-4B.f16.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 7.3G |
| **Arch** | 4B dense, f16 |
| **VRAM** | ~7.5GB |

**Evaluation: ★★★★☆** — Specialized JP→EN translator. Trained on fiction data. 2-5× faster than 27B path on simple chapters. **Use for:** fast translation draft path (low-medium difficulty).

### Kimi-VL-A3B-Thinking-2506-MXFP4_MOE.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 8.7G |
| **Arch** | MoE 3B active, MXFP4 |
| **VRAM** | ~9GB |

**Evaluation: ★★★☆☆** — Vision + thinking MoE. VL capability for future manga OCR pipeline.

### gemma-3-it-12B-Q8_0.gguf

| Attribute | Value                           |
| --------- | ------------------------------- |
| **Path**  | `~/Downloads/llm_models/` (ssd) |
| **Size**  | 12G                             |
| **Arch**  | 12B dense, Q8_0                 |
| **VRAM**  | ~12GB — P40 only for full offload; 3060 with `-ngl` partial offload |

**Evaluation: ★★★★☆** — Near-lossless quantization of Gemma-3 12B. Q8 preserves full quality. 12GB file pushes 3060 limit — may need `-ngl` to keep some layers on CPU. **Best for:** editor (primary).

### gemma-3-12b-it-vl-polaris-glm-4.7-flash-var-thinking-instruct-heretic-uncensored-q8_0.gguf

| Attribute | Value                                      |
| --------- | ------------------------------------------ |
| **Path**  | `/mnt/data/model_storage/`                 |
| **Size**  | 12G                                        |
| **Arch**  | 12B dense, Q8_0, polaris/heretic fine-tune |
| **VRAM**  | ~12GB — P40 only for full offload; 3060 with `-ngl` partial offload |

**Evaluation: ★★★☆☆** — Experimental fine-tune of Gemma-3 12B at Q8. Same VRAM footprint but different training mix. Needs A/B testing vs primary editor. **Use for:** experimental editor A/B test.

### gemma-4-26B-A4B-APEX-Compact.gguf

See P40 section. 14G file needs ~14GB VRAM — exceeds 3060 for full offload. Move to P40 or use partial offloading. Currently assigned to [[glossary]]/continuity on P40.

---

## GPU 1 (Tesla P40 24GB)

Fits models up to ~20GB.

### PromptEnhancer-32B.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 19G |
| **Arch** | 32B dense, i1-Q4_K_M |
| **VRAM** | ~20GB (fits P40 with ~4GB headroom) |

**Evaluation: ★★★★★** — Best comprehension model. 32B dense gives best cross-document reasoning. **Best for:** verifier (current role).

### Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 19G |
| **Arch** | 32B dense, i1-Q4_K_M, Rombo-TIES merge |
| **VRAM** | ~20GB |

**Evaluation: ★★★★☆** — Excellent for comparison/diff tasks. Qwen2.5-Coder base is strong at structured text analysis. **Best for:** consistency checker.

### DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 17G |
| **Arch** | 24B dense, q5_k_m |
| **VRAM** | ~18GB (6GB headroom on P40) |

**Evaluation: ★★★★★** — "Deep Thinker" reasoning. D_AU training targets quality needed for analysis. **Best for:** narrative briefer (current role).

### Qwen3.6-27B-Q4_K_M.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 16G |
| **Arch** | 27B dense, Q4_K_M |
| **VRAM** | ~17GB (7GB headroom on P40) |

**Evaluation: ★★★★☆** — Strong multilingual support (Japanese + Chinese). 27B dense. **Best for:** translator.

### gemma-4-26B-A4B-APEX-Compact.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `/mnt/data/model_storage/` |
| **Size** | 14G |
| **Arch** | MoE 4/26 active (~7B), Q4_K_M |
| **VRAM** | ~14GB (all expert weights loaded) |

**Evaluation: ★★★★☆** — Swiss army knife. 14G fits P40 comfortably. **Best for:** [[glossary]] updater, continuity updater.

### Other Gemma-4-26B variants (P40)

| File | Size | Notes |
|------|------|-------|
| `gemma-4-26B-A4B-APEX-Compact.gguf` | 14G | Pipeline primary |
| `gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf` | 20G | Larger quality variant |
| `gemma-4-26B-A4B-it-Q4_K_M.gguf` | 16G | Stock instruct |
| `gemma-4-26B-A4B-it-uncensored-Q4_K_M.gguf` | 16G | [[hat-unfiltered]] instruct |
| `gemma-4-26B-A4B-it-Claude-Opus-Distill.q4_k_m.gguf` | 16G | Claude Opus distill |
| `supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf` | 16G | [[hat-unfiltered]] fast variant |

All are 26B MoE (4B active). File size ≈ VRAM usage. Larger variants (>14G) may require partial offloading on P40's 24GB.

### Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE.gguf

| Attribute | Value |
|-----------|-------|
| **Path** | `~/Downloads/llm_models/` (ssd) |
| **Size** | 16G |
| **Arch** | MoE 3B active (30B total), MXFP4 |
| **VRAM** | ~16GB |

**Evaluation: ★★☆☆☆** — Vision model. Only useful for future manga/OCR pipeline. **Avoid for text-only roles.**

### Other P40 models

| File | Size | Notes |
|------|------|-------|
| `gpt-oss-20b-hermes.Q5_K_M.gguf` | 16G | 20B general (model_storage + Downloads) |
| `Qwen2.5-Coder-14B-Instruct-Uncensored.Q8_0.gguf` | 15G | 14B dense (model_storage + Downloads) |
| `L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf` | 17G | MoE 12B active |
| `Llama3.2-24B-A3B-II-Dark-Champion-INSTRUCT-Heretic-Abliterated-Uncensored.i1-Q6_K.gguf` | 14G | MoE 3B active |
| `deepseek-moe-16b-base.Q8_0.gguf` | 17G | MoE 16B base |

### Non-LLM / Support

| File | Location | Size | Purpose |
|------|----------|------|---------|
| `mmproj.gguf` | `~/Downloads/llm_models/` | 1.2G | Vision encoder |
| `mmproj-BF16.gguf` | `~/Downloads/llm_models/` + `/mnt/data/model_storage/` | 1.1G | Vision encoder (BF16) |
| `Qwen.Qwen3-VL-Embedding-2B.Q4_K_M.gguf` | `~/Downloads/llm_models/` | 1.1G | Embedding model |

---

## Evaluation Summary

| Tier | Models | Best For |
|------|--------|----------|
| **★★★★★** Excellent | `PromptEnhancer-32B`, `DS4X8R1L3.1-Dp-Thnkr-24B` | Verification, briefer |
| **★★★★☆** Very Good | `Qwen3.6-27B`, `Qwen2.5-Coder-32B`, `gemma-4-APEX-Compact`, `Floppa-12B`, `gemma-3-it-12B-Q8_0`, `text-to-cypher-4B`, `QiMing-4B`, `gemma-3-JP-EN-Translator-4B` | Current pipeline roles |
| **★★★☆☆** Decent | `gemma-4-stock-*`, `gpt-oss-20b-hermes`, `mistral-7b`, `Llama3.2-24B-A3B`, `L3-4X8B-MOE` | Fallbacks |
| **★★☆☆☆** Weak | `Qwen3-VL-MoE`, `Kimi-VL-A3B`, `deepseek-moe-16b-base` | Only if nothing else fits |
| **★☆☆☆☆** Not useful | — | — |
