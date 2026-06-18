# Glossary Candidate

**Port:** 8082 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

Discover new terms from each chunk. Append-only to `glossary-candidate.md`. Does NOT modify `glossary-approved.md` — that requires human confirmation.

## Tasks

- Names
- Titles
- Places
- Organizations
- Weapons
- Skills
- Magic
- Cultivation terms
- Relationships
- Special vocabulary

## Current Model

`gemma-4-26B-A4B-APEX-Compact.gguf` — 14G (MoE 4/26 experts, ~7B active)

**Path:** `/mnt/data/model_storage/gemma-4-26B-A4B-APEX-Compact.gguf`

**Research wiki:** [`gemma-4-26B-APEX-Compact` →](../../../../../../ai-model-research/individual-models/gemma-4-26b-apex-compact.md)

**Why this model:**
- **Excellent extraction** — Gemma-4 instruct handles structured classification well
- **Good categorization** — correctly tags term types (name/title/skill/etc.)
- **Stable formatting** — consistent markdown output

> **VRAM note:** 14G MoE model runs on P40 (24GB). File size ≈ VRAM usage in llama.cpp — all expert weights are loaded. Does not fit RTX 3060.


## Alternatives (P40)

| Model | Size | Tradeoff |
|-------|------|----------|
| `gemma-4-26B-A4B-it-Q4_K_M.gguf` | 16G | Stock Gemma-4, less fine-tuned |
| `gemma-4-26B-A4B-it-uncensored-Q4_K_M.gguf` | 16G | May produce NSFW glossaries |
