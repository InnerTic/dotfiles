# Editor

**Port:** 8084 | **GPU:** 3060 (CUDA0) | **Context:** 4096

## Role

Takes literal translation and improves readability / natural English prose.

**Allowed:** grammar fixes, flow improvement, natural English, minor sentence cleanup.
**Forbidden:** adding emotion/atmosphere/implications, changing meaning, changing names/glossary, dropping honorifics, inventing details.

## Output

- Edited text
- Edit log
  - Sentence compressed? yes/no
  - Tone shift? none/mild/moderate (must justify)
  - Reordering? yes/no
  - Justification

## Primary Model

`gemma-3-it-12B-Q8_0.gguf` — 12G, 12B params (dense, Q8_0)

**Path:** `~/Downloads/llm_models/gemma-3-it-12B-Q8_0.gguf`

**Research wiki:** [`gemma-3-12B-it-Q8` →](../../../../../../ai-model-research/individual-models/gemma-3-12b-it-q8.md)

**Why this model:**
- **12B dense at Q8** — near-lossless quality, best output quality for 3060
- **Gemma-3 base** — strong instruction following for constrained editing
- **Uncensored** — won't refuse or rephrase controversial content

**Note:** 12GB file pushes 3060's 12GB VRAM limit. May need `-ngl` partial offloading.

## Experimental Model

`gemma-3-12b-it-vl-polaris-glm-4.7-flash-var-thinking-instruct-heretic-uncensored-q8_0.gguf` — 12G, 12B params (dense, Q8_0)

**Path:** `/mnt/data/model_storage/gemma-3-12b-it-vl-polaris-glm-4.7-flash-var-thinking-instruct-heretic-uncensored-q8_0.gguf`

**Research wiki:** [`gemma-3-12B-polaris-heretic` →](../../../../../../ai-model-research/individual-models/gemma-3-12b-polaris-heretic.md)

Fine-tuned variant of Gemma-3 12B at Q8. Same VRAM footprint as primary. For A/B testing — verifier determines which produces fewer issues.

## Alternatives

| Model | Size | Tradeoff |
|-------|------|----------|
| `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 6.8G | Proven fit on 3060. Good fallback if Q8 models don't fit. |
