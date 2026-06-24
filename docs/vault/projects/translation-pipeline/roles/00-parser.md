# Parser

**Port:** 8080 | **GPU:** 3060 (CUDA0) | **Context:** 2048 | **Temp:** 0.1

## Role

Break Japanese or Chinese text into explicit structural information.

This stage does NOT translate — pure extraction of structural metadata.

## Tasks

- Characters
- Speakers
- Locations
- Organizations
- Scene boundaries
- Pronoun candidates
- Honorific relationships
- Time shifts
- Flashbacks
- POV shifts
- Explicit subjects
- Implicit subjects

## Output

`parser-summary.md`

## Current Model

`text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` — 7.3G, 4B params (dense, f16)

**Path:** `~/Downloads/llm_models/text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf`

**Research wiki:** [`text-to-cypher-4B` →](../../../../../../ai-model-research/individual-models/text-to-cypher-4b.md)

**Why this model:**
- **Small (4B)** — fast inference, fits 3060 with headroom
- **Gemma-3 base** — strong instruction following for structured extraction
- **Specialized task** — no reasoning needed, just identify and classify entities
- **Low temperature (0.1)** — deterministic output, minimal hallucination risk

## Alternatives

| Model                                         | Size | Tradeoff                             |
| --------------------------------------------- | ---- | ------------------------------------ |
| `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 6.8G | Overkill for extraction, slower      |
