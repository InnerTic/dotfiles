# Pipeline Roles

Each stage is a separate model that gets loaded on its GPU, serves one API call, then unloaded. Models are swappable — see each role's page for current model + alternatives.

| # | Role | Model (Current) | GPU | Port | File |
|---|------|-----------------|-----|------|------|
| 1 | [[01-glossary-updater\|Glossary Updater]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 3060 | 8082 | [[01-glossary-updater]] |
| 2 | [[02-briefer\|Briefer (PromptEnhancer)]] | `PromptEnhancer-32B.i1-Q4_K_M.gguf` | P40 | 8081 | [[02-briefer]] |
| 3 | [[03-translator\|Translator]] | `Qwen3.6-27B-Q4_K_M.gguf` | P40 | 8083 | [[03-translator]] |
| 4 | [[04-editor\|Editor]] | `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 3060 | 8084 | [[04-editor]] |
| 5 | [[05-script-checks\|Script Checks]] | grep/awk/jq (deterministic) | — | — | [[05-script-checks]] |
| 6 | [[06-consistency-checker\|Consistency Checker]] | `Qwen2.5-Coder-32B-Rombo-TIES.i1-Q4_K_M.gguf` | P40 | 8086 | [[06-consistency-checker]] |
| 7 | [[07-verifier\|Verifier]] | `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` | P40 | 8085 | [[07-verifier]] |
| 8 | [[08-continuity-updater\|Continuity Updater]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 3060 | 8088 | [[08-continuity-updater]] |

## Model Inventory

All available LLMs across storage paths, sorted by effective size. See [[model-index\|full model index]] for evaluation notes.

### GPU 0 (RTX 3060 12GB)
Fits models ≤7GB effective (dense) or MoE with ~4-7 active experts.
- `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` — 6.8G (12B dense)
- `gemma-2-2b-it-Q6_K_L.gguf` — 2.2G (2B dense)

### GPU 1 (Tesla P40 24GB)
Fits models up to ~20GB.
- `PromptEnhancer-32B.i1-Q4_K_M.gguf` — 19G (32B, ssd)
- `Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf` — 19G (32B, ssd)
- `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` — 17G (24B, ssd)
- `Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE.gguf` — 16G (MoE 4B active, ssd)
- `Qwen3.6-27B-Q4_K_M.gguf` — 16G (27B, model_storage)
- `L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf` — 17G (MoE, model_storage)
- `gemma-4-26B-A4B-APEX-Compact.gguf` — 14G (MoE 7B active, model_storage)
- `gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf` — 20G (MoE 7B active, ssd)
- `gemma-4-26B-A4B-it-Q4_K_M.gguf` — 16G (stock, model_storage)
- `gemma-4-26B-A4B-it-uncensored-Q4_K_M.gguf` — 16G (stock uncensored, model_storage)
- `gemma-4-26B-A4B-it-Claude-Opus-Distill.q4_k_m.gguf` — 16G (distill, model_storage)
- `supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf` — 16G (fast, model_storage)
- `Llama3.2-24B-A3B-II-Dark-Champion-INSTRUCT-Heretic-Abliterated-Uncensored.i1-Q6_K.gguf` — 14G (MoE 3B active, model_storage)
- `Llama-3.2-4X3B-MOE-Ultra-Instruct-10B-D_AU-Q8_0.gguf` — 9.9G (MoE, model_storage)
- `Qwen2.5-Coder-14B-Instruct-Uncensored.Q8_0.gguf` — 15G (14B dense, ssd+ms)
- `Qwen3.5-21B-Claude-4.6-Opus-Deckard-Heretic-Uncensored-Thinking.i1-Q5_K_M.gguf` — 14G (21B, model_storage)
- `LLMBG-ToolUse-27B-v1.0.i1-Q4_K_M.gguf` — 16G (27B tool, model_storage)
- `OpenAI-20B-NEO-Uncensored2-Q5_1.gguf` — 16G (20B, model_storage)
- `gpt-oss-20b-hermes.Q5_K_M.gguf` — 16G (20B general, ssd+ms)

### Non-LLM
- `mmproj.gguf` — 1.2G (vision encoder, ssd)
- `mmproj-BF16.gguf` — 1.1G (vision encoder, ssd)
- `Qwen.Qwen3-VL-Embedding-2B.Q4_K_M.gguf` — 1.1G (embedding, ssd)
- `DetailsNature2.safetensors` — 19M (LoRA/safetensors, ssd)
