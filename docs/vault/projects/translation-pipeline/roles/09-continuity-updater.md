# Continuity Updater

**Port:** 8088 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

After human approval, update the project's canon database.

## Updates

- Equipment — acquired, lost, upgraded
- Injuries — sustained, healed, permanent
- Deaths
- Relationships — new, changed, ended
- Locations — moved, discovered, returned
- Skills — learned, mastered
- Titles — earned, lost

Plus:
- Scene index
- Timeline

## Hard Facts vs Soft Facts

**Hard Facts** (update automatically):
- Sword acquired
- Arm broken
- Character died
- Moved to new city

**Soft Facts** (human approval required):
- Character is suspicious
- Character is angry
- Character is possibly jealous

## Current Model

`gemma-4-26B-A4B-APEX-Compact.gguf` — 14G (MoE 4/26 experts, ~7B active)

**Path:** `/mnt/data/model_storage/gemma-4-26B-A4B-APEX-Compact.gguf`

**Research wiki:** [`gemma-4-26B-APEX-Compact` →](../../../../../../ai-model-research/individual-models/gemma-4-26b-apex-compact.md)

Shares the same model as Glossary Candidate (step 1) on a different port.

**Why this model:**
- **Same as glossary** — keeps disk footprint small
- **Structured diff output** — compact instruct variant follows formatting well

> **VRAM note:** 14G MoE model runs on P40 (24GB). Does not fit RTX 3060.

## Alternatives

Same as [[01-glossary-updater#Alternatives]].

| Model                                         | Size | Arch      | Tradeoff                                                                                      |
| --------------------------------------------- | ---- | --------- | --------------------------------------------------------------------------------------------- |
| `gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf` | 20G  | MoE ~7B   | Same MoE, larger file. No upside.                                                             |
