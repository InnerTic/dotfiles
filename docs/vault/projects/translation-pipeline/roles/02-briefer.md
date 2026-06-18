# Narrative Briefer

**Port:** 8081 | **GPU:** P40 (CUDA1) | **Context:** 4096

## Role

Build context for later verification stages. Does NOT translate.

Extracts narrative metadata from the parser output and raw chunk to create a structured briefing for the Verifier.

## Tasks

- Characters present
- Relationships between characters
- Locations
- Referenced events (prior chapters)
- Scene purpose
- Timeline position
- Ambiguity anchors (unclear pronoun references, dual meanings)
- Speaker uncertainty markers
- Pronoun mappings (who is "he"/"she"/"they")
- Flashbacks or time jumps
- Character motivations
- Potential translation traps

## Output

`briefing.md`

## Current Model

`DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` — 17G, 24B params (dense)

**Path:** `~/Downloads/llm_models/DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf`

**Research wiki:** [`DS4X8R1L3.1-Dp-Thnkr-24B` →](../../../../../../ai-model-research/individual-models/ds4x8r1l3-dp-thnkr-24b.md)

**Why this model:**
- **24B dense** — good reasoning capacity for ambiguity analysis
- **Deep Thinker** — trained for careful, multi-step analysis
- **D_AU (Detailed, Accurate, Useful)** — directly targets structured context building
- **Q5_K_M** — higher quality quantization for analysis tasks

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `PromptEnhancer-32B.i1-Q4_K_M.gguf` | 19G | More params, better extraction. Current verifier model. |
| `gpt-oss-20b-hermes.Q5_K_M.gguf` | 16G | 20B dense. Less specialized but available. |
