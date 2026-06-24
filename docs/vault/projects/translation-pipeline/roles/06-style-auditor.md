# Style Auditor

**Port:** 8086 | **GPU:** 3060 (CUDA0) | **Context:** 2048

## Role

Check edited translation against the project's Style Bible. Pure style compliance — does NOT evaluate translation quality.

## Inputs

- Style Bible
- Edited text (from Editor stage)

## Checks

- Honorifics preserved per style rules
- Quote style matches bible (straight vs. curly, which character)
- Thought formatting matches bible (italic, asterisk, none)
- Capitalization rules followed
- Named style rules enforced (e.g. "Magic Stone" not "magic stone", "Onee-sama" not "onee-sama")
- Known character-specific speech patterns maintained

## Output

Issue report with severity (HIGH/MEDIUM/LOW). No rewriting.

## Current Model

`QiMing-Gemma-3-4b.f16.gguf` — 7.3G, 4B params (dense, f16)

**Path:** `/mnt/data/model_storage/QiMing-Gemma-3-4b.f16.gguf`

**Research wiki:** [`QiMing-Gemma-3-4B` →](../../../../../../ai-model-research/individual-models/qiming-gemma-3-4b.md)

**Why this model:**
- **4B Gemma-3 variant** — good rule enforcement capability
- **Specialist role** — style bible compliance is a classification task, not deep reasoning
- **Fits 3060** — 7.3GB leaves ~4GB headroom on 12GB card

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` | 7.3G | Same size, same base. Slightly different specialization. |
| `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 6.8G | Overkill for style audit but proven fit on 3060 |
| grep/awk/jq | — | Deterministic but can't handle fuzzy style rules |
