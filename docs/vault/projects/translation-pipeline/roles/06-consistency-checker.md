# Consistency Checker

**Port:** 8086 | **GPU:** P40 (CUDA1) | **Context:** 8192

## Role

Compares current chunk against prior chunks (1, 5, 9, 14) for:
- Terminology drift — same Japanese term, different English
- Speaker attribution — who said what changes between chunks
- Dialogue flow — unnatural jumps or repetitions
- Possible duplicated meaning — same info restated
- Paragraph order — out-of-sequence text

**Advisory only** — flags are superseded by Verifier findings.

**Conditional:** Only runs when Script Checks find HIGH issues. Most chunks skip this step (fast path).

## Current Model

`Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf` — 19G, 32B params (dense)

**Path:** `/home/ken/Downloads/llm_models/Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf`

**Why this model:**
- **32B params** — needs to compare text spans accurately
- **Qwen2.5-Coder** — surprisingly good at diff/comparison tasks vs general instruct models. The coder training helps with exact text matching.
- **Rombo-TIES merge** — retains coder precision while adding instruction following
- **Abliterated** — no refusals for comparing problematic text
- **8192 context** — needs room for 4 prior chunks + current chunk

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Qwen2.5-Coder-14B-Instruct-Uncensored.Q8_0.gguf` | 15G | 14B, Q8. Half the params but higher quantization. Faster. Good enough for simple drift detection. |
| `LLMBG-ToolUse-27B-v1.0.i1-Q4_K_M.gguf` | 16G | 27B tool-use. May over-structure the comparison output. |
| `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` | 17G | 24B "deep thinker" — slow but thorough. Currently verifier — would need a different verifier. |
