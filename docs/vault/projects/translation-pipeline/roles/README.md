# Pipeline Roles

Each stage is a separate model that gets loaded on its GPU, serves one API call, then unloaded. Models are swappable — see each role's page for current model + alternatives.

## Role Table

| #   | Role                                            | Model                                                   | Size | GPU  | Port | File                       |
| --- | ----------------------------------------------- | ------------------------------------------------------- | ---- | ---- | ---- | -------------------------- |
| 0   | [[00-parser\|Parser]]                           | `text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` | 7.3G | 3060 | 8080 | [[00-parser]]              |
| 1   | [[01-glossary-updater\|Glossary Candidate]]     | `gemma-4-26B-A4B-APEX-Compact.gguf`                     | 14G  | P40  | 8082 | [[01-glossary-updater]]    |
| 2   | [[02-briefer\|Narrative Briefer]]               | `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf`         | 17G  | P40  | 8081 | [[02-briefer]]             |
| 3   | [[03-translator\|Literal Translator]]           | `Qwen3.6-27B-Q4_K_M.gguf`                               | 16G  | P40  | 8083 | [[03-translator]]          |
| 4   | [[04-editor\|Editor]]                           | `gemma-3-it-12B-Q8_0.gguf`                              | 12G  | 3060 | 8084 | [[04-editor]]              |
| 5   | [[05-script-checks\|Script Checks]]             | grep/awk/jq                                             | —    | —    | —    | [[05-script-checks]]       |
| 6   | [[06-style-auditor\|Style Auditor]]             | `QiMing-Gemma-3-4b.f16.gguf`                            | 7.3G | 3060 | 8086 | [[06-style-auditor]]       |
| 7   | [[07-consistency-checker\|Consistency Checker]] | `Qwen2.5-Coder-32B-Rombo-TIES.i1-Q4_K_M.gguf`           | 19G  | P40  | 8087 | [[07-consistency-checker]] |
| 8   | [[08-verifier\|Verifier]]                       | `PromptEnhancer-32B.i1-Q4_K_M.gguf`                     | 19G  | P40  | 8085 | [[08-verifier]]            |
| 9   | [[09-continuity-updater\|Continuity Updater]]   | `gemma-4-26B-A4B-APEX-Compact.gguf`                     | 14G  | P40  | 8088 | [[09-continuity-updater]]  |

## Pipeline Flow

```
Raw Text → Parser → Glossary → Briefer → Translator → Editor
  → Script Checks → Style Auditor → Consistency → Verifier
  → Continuity → Human Review → Glossary Reconciliation → Final Output
```

## Model Inventory

See [[model-index\|full model index]] for evaluation notes.

### GPU 0 (RTX 3060 12GB)
Fits models with file size ≤~9GB (leaving ~2-3GB for KV cache + CUDA overhead).

- `text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` — 7.3G (4B dense, parser)
- `QiMing-Gemma-3-4b.f16.gguf` — 7.3G (4B dense, style auditor)
- `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` — 6.8G (12B dense, editor fallback)
- `gemma-3-it-12B-Q8_0.gguf` — 12G (12B dense Q8, editor — borderline, may need `-ngl`)

### GPU 1 (Tesla P40 24GB)
Fits models up to ~20GB.

- `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` — 17G (24B, briefer)
- `Qwen3.6-27B-Q4_K_M.gguf` — 16G (27B, translator)
- `PromptEnhancer-32B.i1-Q4_K_M.gguf` — 19G (32B, verifier)
- `Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf` — 19G (32B, consistency)
- `gemma-4-26B-A4B-APEX-Compact.gguf` — 14G (MoE, glossary + continuity)

### Non-LLM
- `mmproj.gguf` — 1.2G (vision encoder, ssd)
- `mmproj-BF16.gguf` — 1.1G (vision encoder, ssd)
- `Qwen.Qwen3-VL-Embedding-2B.Q4_K_M.gguf` — 1.1G (embedding, ssd)
