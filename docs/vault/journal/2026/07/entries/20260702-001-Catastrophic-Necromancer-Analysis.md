---
type: work-entry
id: 20260702-001
status: completed
confidence: high
time_spent: 2.5h
projects:
  - "[[Translation Pipeline]]"
  - "[[Catastrophic Necromancer]]"
daily:
  - "[[2026-07-02]]"
systems:
  - "[[llama.cpp]]"
  - "[[gemma-4-26B]]"
scripts:
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/scripts/01-consistency-check.py
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/scripts/02-run-model-jobs.py
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/scripts/03-clean.py
files:
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/consistency-report.md
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/model-jobs.json
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/clean-report.md
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/model-responses/{name_consistency,dialogue_quality,recap_classification,promo_strip_verify,tone_drift}.md
created_pages:
  - "[[2026-07-02]]"
  - "[[20260702-001-Catastrophic-Necromancer-Analysis]]"
updated_pages:
  - "[[AGENTS]]"
tags:
  - translation
  - qc
  - consistency
  - web-novel
  - llama-cpp
---

# 20260702-001 — Catastrophic Necromancer Analysis

Date: 2026-07-02

## Goal

Run no-AI and model-assisted consistency checks on all 4,851 chapters of "Catastrophic Necromancer" (全民转职：死灵法师！我即是天灾), then apply cleanups.

## Approach

Three-script pipeline:

1. **01-consistency-check.py** — No-model checks: straight quote scan, promo detection, length outlier detection, trailing artifact scan. Outputs `consistency-report.md` + `model-jobs.json` (5 structured jobs for local AI).
2. **02-run-model-jobs.py** — Feeds each job to gemma-4-26B on port 8080 with actual chapter text in prompt. Retry-safe, outputs per-job `.md` to `model-responses/`.
3. **03-clean.py** — Applies fixes: strips promo lines (39 regex patterns), fixes "Lin Muyu" → "Lin Moyu", removes trailing non-story lines from final chapters. Writes to `clean/`, keeps `raw/` untouched.

## Results

### No-AI checks
- **1,016** straight double-quote artifacts (bare `"` where curly `""` used elsewhere — copy-paste artifacts)
- **3,310** promo spam occurrences across 39 patterns (Patreon, Ko-fi, Discord, other novel ads)
- **42** chapter length outliers: ch0429 (947 chars, -88%) and ch0439 (1,139 chars, -86%) likely truncated; ch0225–ch0231 block 12–13k likely merged
- **2** trailing artifacts in ch4851

### Model jobs (gemma-4-26B on P40)
- **Name consistency**: Found `Lin Muyu` → `Lin Moyu` variant. Other 8 named characters consistent.
- **Dialogue quality**: No issues detected.
- **Recap classification**: 24/30 story_recap (keep), 4 promo/strip, 1 site_notice, 1 separator.
- **Promo strip verify**: Empty output (model didn't produce).
- **Tone drift**: Style consistent; quality degradation in late chapters (ch4840 title repetition, ch4850 raw translator notes).

### Cleanup applied
- **2,891 name fixes** (Lin Muyu → Lin Moyu) across 112 chapters
- **3,268 promo lines** removed from 1,399 chapters
- **7 trailing non-story lines** stripped from ch4850–ch4851
- Clean output written to `clean/` (4,851 files)

## Lessons

- Model prompts must include actual chapter text, not just chapter numbers (initial bug: model replied "provide the text for the chapters listed")
- gemma-4-26B on P40 handles structured QC tasks well but can OOM on long-context requests with concurrent jobs
- `model-jobs.json` pattern (instruction + sampled data) is reusable for any corpus QC task
- "Lin Muyu" vs "Lin Moyu" is a ü→u romanization variant, common in MTI translations
- AGENTS.md model offloading description was wrong (claimed "small model on 3060"; corrected to P40 + 3060 split)

## Next Steps

- Re-run promo_strip_verify with shorter prompt to get model confirmation
- Investigate truncated chapters (ch0429, ch0439, ch0011) — check if content is genuinely short or cut off
- Apply same pipeline pattern to Hyperdimensional Sorcerer after parser pass completes
