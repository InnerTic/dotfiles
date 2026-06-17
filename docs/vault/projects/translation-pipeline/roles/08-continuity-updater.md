# Continuity Updater

**Port:** 8088 | **GPU:** 3060 (CUDA0) | **Context:** 4096

## Role

After human approval, updates:
- `characters.md` — acquired items, injuries, location changes, relationship changes, deaths
- `scene-index.md` — new scene entries with location, time, speakers, mood_tag

Receives: approved translation + verifier report. Outputs structured diff for both files.

## Current Model

`gemma-4-26B-A4B-APEX-Compact.gguf` — 14G on disk, ~7B active params (MoE 4/26 experts)

**Path:** `/mnt/data/model_storage/gemma-4-26B-A4B-APEX-Compact.gguf`

Shares the same model as Glossary Updater (step 1) on a different port. Both load/unload as needed.

**Why this model:**
- **Same as glossary updater** — keeps disk footprint small, only one Gemma MOE download
- **Structured diff output** — the compact instruct variant follows formatting well
- **MoE efficiency** — 7B active fits 3060, leaving enough room for the context window
- **Separate port (8088)** — avoids port conflicts if glossary updater is still running (though sequential pipeline means this is theoretical)

## Alternatives

Same as [[01-glossary-updater#Alternatives]].

| Model | Size | Active | Tradeoff |
|-------|------|--------|----------|
| `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 6.8G | 12B | Dense, better at state tracking but more creative — may introduce incorrect changes. |
| `gemma-4-26B-A4B-heretic-APEX-I-Quality.gguf` | 20G | ~7B | Same MoE quality, larger disk file. No upside. |

**If continuity tracking needs improvement:** Consider swapping the glossary/continuity model to `Floppa` (dense 12B) for better state reasoning, or move this role to P40 and use `Qwen2.5-Coder-14B-Uncensored.Q8_0` for precise structured output.
