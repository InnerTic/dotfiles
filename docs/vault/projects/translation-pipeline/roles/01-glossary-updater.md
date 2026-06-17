# Glossary Updater

**Port:** 8082 | **GPU:** 3060 (CUDA0) | **Context:** 4096

## Role

Extracts new terms, titles, locations, organizations, and relationships from each chunk. Appends candidate entries to `glossary-candidate.md`. Does NOT touch `glossary-approved.md` — that requires human confirmation.

## Current Model

`gemma-4-26B-A4B-APEX-Compact.gguf` — 14G on disk, ~7B active params (MoE 4/26 experts)

**Path:** `/mnt/data/model_storage/gemma-4-26B-A4B-APEX-Compact.gguf`

**Why this model:**
- **MoE efficiency** — only ~7B active params, fits 3060's 12GB with headroom despite 14G disk size
- **Gemma-4 instruct** — good at structured extraction tasks, follows formatting instructions
- **Compact variant** — the "compact" instruction-tuned version avoids creative drift

## Alternatives (3060-friendly, ≤7GB effective)

| Model | Size | Active | Tradeoff |
|-------|------|--------|----------|
| `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 6.8G | 12B | Dense, creative — may invent terms. Better as editor. |
| `gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf` | 20G | ~7B | Same active size but uses more disk; no functional advantage for extraction. |
| `gemma-2-2b-it-Q6_K_L.gguf` | 2.2G | 2B | Too small — misses subtle terminology relationships. |

## Alternatives (P40-only, >12GB)

These could run on P40 if 3060 is busy with Forge:

| Model | Size | Tradeoff |
|-------|------|----------|
| `gemma-4-26B-A4B-it-Q4_K_M.gguf` | 16G | Stock Gemma-4, less fine-tuned for extraction |
| `gemma-4-26B-A4B-it-uncensored-Q4_K_M.gguf` | 16G | May produce NSFW glossaries |
| `supergemma4-26b-uncensored-fast-v2-Q4_K_M.gguf` | 16G | Faster inference, potentially lower quality |
