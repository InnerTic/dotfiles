# Consistency Checker

**Port:** 8087 | **GPU:** P40 (CUDA1) | **Context:** 8192

## Role

Compare current chunk against project history.

Inputs:
- Prior chunks (1, 5, 9, 14)
- Human corrections
- Recent [[glossary]] [[changelog]]
- Scene index
- Timeline
- Continuity updates

Checks:
- Terminology drift — same Japanese term, different English
- Speaker attribution — who said what [[changelog]] between chunks
- Dialogue flow — unnatural jumps or repetitions
- Repeated information — same info restated across chunks
- Paragraph ordering — out-of-sequence text
- POV drift — character perspective [[changelog]] unexpectedly
- Character voice — dialogue patterns inconsistent
- Timeline issues — chronological contradictions

**Advisory only** — flags are superseded by Verifier findings.

## Current Model

`Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf` — 19G, 32B params (dense)

**Path:** `/home/ken/Downloads/llm_models/Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf`

**Research wiki:** [`Qwen2.5-Coder-32B-Rombo-TIES` →](../../../../../../ai-model-research/individual-models/qwen2.5-coder-32b-rombo-ties.md)

**Why this model:**
- **32B params** — needs to compare text spans accurately
- **Qwen2.5-Coder** — excellent at diff/comparison tasks. Coder training helps with exact text matching.
- **Rombo-TIES merge** — retains coder precision while adding instruction following
- **8192 context** — needs room for multiple prior chunks + current chunk

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Qwen2.5-Coder-14B-Instruct-Uncensored.Q8_0.gguf` | 15G | 14B, Q8. Half the params but faster. Good for simple drift detection. |
| `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` | 17G | 24B "deep thinker" — slow but thorough. |
| `L3-4X8B-MOE-Dark-Planet-Infinite-25B-D_AU-q5_k_m.gguf` | 17G | MoE 25B. Different architecture — test before relying on it. |
