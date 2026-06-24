# Translation Pipeline v2.0

**Source:** `/mnt/data/_translation-pipeline/translation-pipeline/`

A production workflow for translating Japanese & Chinese web novels while preserving character continuity, terminology, honorifics, and literary style.

## Design Philosophy

- **Small models** perform deterministic extraction.
- **Medium models** perform constrained editing.
- **Large models** perform reasoning.
- **Humans** approve canon.

No model should perform work outside its specialty.

## GPU Layout

| GPU | Roles | Capacity |
|-----|-------|----------|
| **RTX 3060** (CUDA0, 12GB) | Parser, Editor, Style Auditor | Models ≤~9GB file |
| **Tesla P40** (CUDA1, 24GB) | [[glossary]], Briefer, Translator, Consistency, Verifier, Continuity | Models up to ~20GB |

> **VRAM note:** MoE models do NOT save VRAM in llama.cpp — all expert weights are loaded per offloaded layer. File size ≈ VRAM usage for full offload.

## Roles

| # | Role | Model | Size | GPU | Port | Details |
|---|------|-------|------|-----|------|---------|
| 0 | [[translation-pipeline/roles/00-parser\|Parser]] | `text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` | 7.3G | 3060 | 8080 | [[translation-pipeline/roles/00-parser\|role →]] |
| 1 | [[translation-pipeline/roles/01-glossary-updater\|Glossary Candidate]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 14G | P40 | 8082 | [[translation-pipeline/roles/01-glossary-updater\|role →]] |
| 2 | [[translation-pipeline/roles/02-briefer\|Narrative Briefer]] | `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` | 17G | P40 | 8081 | [[translation-pipeline/roles/02-briefer\|role →]] |
| 3 | [[translation-pipeline/roles/03-translator\|Literal Translator]] | `Qwen3.6-27B-Q4_K_M.gguf` | 16G | P40 | 8083 | [[translation-pipeline/roles/03-translator\|role →]] |
| 4 | [[translation-pipeline/roles/04-editor\|Editor]] | `gemma-3-it-12B-Q8_0.gguf` | 12G | 3060 | 8084 | [[translation-pipeline/roles/04-editor\|role →]] |
| 5 | [[translation-pipeline/roles/05-script-checks\|Script Checks]] | Deterministic validation gate | — | — | — | [[translation-pipeline/roles/05-script-checks\|role →]] |
| 6 | [[translation-pipeline/roles/06-style-auditor\|Style Auditor]] | `QiMing-Gemma-3-4b.f16.gguf` | 7.3G | 3060 | 8086 | [[translation-pipeline/roles/06-style-auditor\|role →]] |
| 7 | [[translation-pipeline/roles/07-consistency-checker\|Consistency Checker]] | `Qwen2.5-Coder-32B-Rombo-TIES.i1-Q4_K_M.gguf` | 19G | P40 | 8087 | [[translation-pipeline/roles/07-consistency-checker\|role →]] |
| 8 | [[translation-pipeline/roles/08-verifier\|Verifier]] | `PromptEnhancer-32B.i1-Q4_K_M.gguf` | 19G | P40 | 8085 | [[translation-pipeline/roles/08-verifier\|role →]] |
| 9 | [[translation-pipeline/roles/09-continuity-updater\|Continuity Updater]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 14G | P40 | 8088 | [[translation-pipeline/roles/09-continuity-updater\|role →]] |

> **Port note:** Port 8080 is llama.cpp's default. Since the pipeline runs one model at a time, ports are always available when needed. If you start a second [[llama-server]] outside the pipeline, it auto-assigns a different port — no conflict.

## Pipeline

```
Raw Text
    |
    V
[0] Parser — text-to-cypher (port 8080)
    Extract: characters, speakers, locations, scenes, POV, time shifts
    Output: parser-summary.md
    |
    V
[1] Glossary Candidate — Gemma MOE (port 8082)
    Discover new terms, categorize (name/title/skill/magic/etc.)
    Output: glossary-candidate.md additions (append only)
    |
    V
[2] Narrative Briefer — DS4X8R1L3.1 (port 8081)
    Build context: relationships, timeline, ambiguity anchors, pronoun mappings
    Output: briefing.md
    |
    V
[3] Literal Translator — Qwen3.6 (port 8083)
    Literal translation using approved glossary + parser output
    Output: translation + difficulty assessment
    |
    V
[4] Editor — Gemma-3 12B Q8 (port 8084)
    Improve readability, natural prose
    Preserve: names, terms, meaning, honorifics
    Output: edited text + edit log
    |
    V
[5] Script Checks — Deterministic Validation Gate
    grep/awk/jq — no GPU, no model inference, no heuristics
    Unicode normalization pass before all checks
    Failures are binary (pass/fail) — blocks pipeline if FAIL
    Output: structured JSON issue report
    |
    V
[6] Style Auditor — QiMing-Gemma-3-4b (port 8086)
    Check style bible compliance
    Honorifics, quotes, thought formatting, capitalization
    Output: style issue report
    |
    V
[7] Consistency Checker — Qwen Coder (port 8087)
    Compare against prior chunks + project history
    Check: terminology drift, POV drift, timeline issues
    Output: issue list (advisory only)
    |
    V
[8] Verifier — PromptEnhancer (port 8085)
    Comprehensive QC using all prior stage outputs
    Compare: original, parser, briefer, translation, editor log,
            style audit, glossary, characters, mistakes database
    Severity: HIGH / MEDIUM / LOW
    Do NOT rewrite
    Output: issue report only
    |
    V
[9] Continuity Update — Gemma MOE (port 8088)
    Update: equipment, injuries, deaths, relationships, locations
    Separate hard facts (auto) from soft facts (human approval)
    Output: characters.md diff + scene-index.md diff
    |
    V
[10] Human Review
    Review: translation, verifier report, style audit, script issues
    Structured corrections only (machine-readable)
    |
    V
[11] Glossary Reconciliation — Gemma MOE (port 8082)
    Move approved candidate terms → glossary-approved.md
    Archive to history/ with reason
    Output: glossary diff
    |
    V
[12] Write Output
    Append approved chunk to output/
    Update continuity database
    Update scene index
```

## Key Rules

1. **Parser never translates.**
2. **[[glossary]] never approves.**
3. **Briefer never edits.**
4. **Translator never interprets.**
5. **Editor never invents.**
6. **Script checks never use AI.**
7. **Style Auditor only checks style.**
8. **Consistency only compares.**
9. **Verifier never rewrites.**
10. **Continuity only updates canon.**
11. **Humans decide canon.**
12. **Approved canon becomes project memory.**

## Server Lifecycle

Only **one model loads per GPU at a time**. The pipeline is sequential:

1. Kill any previous server on the target GPU
2. Start the server for the current stage
3. Wait for it to load (15-60s depending on model size)
4. Send the API request
5. Kill the server (or leave it if it's the last stage on that GPU)

Handled automatically by `pipe.sh`.

## Canon Database

Per project:

```
canon/
  characters.md              # Character state (equipment, injuries, relationships)
  timeline.md                # Chapter/scene chronological tracking
  scene-index.md             # Scene segmentation with metadata
  relationship-map.md        # Character relationship tracking
  style-bible.md             # Style rules per project
  glossary-approved.md       # Finalized glossary terms
  glossary-candidate.md      # Pending terms discovered during translation
  translation-decisions.md   # Historical translation rationale
  mistakes.md                # Every major error caught (pipeline learning)
```

### mistakes.md

Stores every significant error caught by the pipeline. Included in future prompts so the pipeline learns from past mistakes.

Example:
```
Date: 2026-06-15
Stage: Editor
Issue: Dropped senpai from dialogue
Verifier caught: Yes
Rule: Never remove honorifics
```

## Scene Index

Per scene:
- Scene ID: `<project>_<chapter>_<scene>`
- Location
- Time
- POV character
- Speakers
- Conflict
- Objective
- Resolution
- Mood
- Cliffhanger
- Next hook

## Difficulty Assessment

Instead of confidence scores:

```
Difficulty: Medium
Reasons:
  - idiom present
  - archaic speech pattern
  - cultural reference
  - pronoun ambiguity
```

Actionable for the human reviewer.

## Glossary System

Two files per project:
- `glossary-approved.md` — finalized, used by Translator
- `glossary-candidate.md` — discovered during translation, pending approval

History:
```
history/
  0001.md    # Each change logged with reason
  0002.md
  ...
```

## Script Checks

Unicode normalization pass (smart quotes → ASCII, em-dashes, etc.) runs before all checks.

Checks against normalized text:
- Quote balance (expect even)
- Bracket balance (expect equal)
- Japanese characters remaining (expect empty)
- Chinese characters remaining (expect empty for JP projects)
- Repeated paragraphs
- Name counts per variant
- Markdown code fence balance (expect even)
- Whitespace consistency
- Honorific counts
- [[glossary]] term counts
- Dialogue count checks
- Capitalization checks
- Duplicate sentence detection

## Scripts

| Command | Action |
|---------|--------|
| `parser.sh` | Start server for this role (3060, port 8080) |
| `glossary-update.sh` | Start server for this role (P40, port 8082) |
| `briefer.sh` | Start server for this role (P40, port 8081) |
| `translate.sh` | Start server for this role (P40, port 8083) |
| `editor.sh` | Start server for this role (3060, port 8084) |
| `script-checks.sh` | Run deterministic checks (grep/awk/jq) |
| `style-audit.sh` | Start server for this role (3060, port 8086) |
| `consistency-check.sh` | Start server for this role (P40, port 8087) |
| `verify.sh` | Start server for this role (P40, port 8085) |
| `continuity-update.sh` | Start server for this role (P40, port 8088) |
| `start-server.sh` | Generic: kill previous server on GPU, start model, wait for ready |
| `stop-server.sh` | Kill server on a given port |
| `pipe.sh` | Run full pipeline on a chunk |

## Future: Manga Support

Partially supported. Future additions:
- `Qwen3-VL` — vision-language model for image understanding
- `mmproj.gguf` — vision encoder
- OCR pipeline
- Panel parser
- Speech bubble ordering

Pipeline becomes:
```
Image → OCR → Parser → Translator → Editor → Verifier → Human
```

## Filesystem

```
/mnt/data/_translation-pipeline/translation-pipeline/
  books/
    <project>/
      raw/                     # Original source text
      canon/                   # Canon database (see above)
      chunks/                  # Tokenized, chunked chapters
      output/                  # Final approved output
      work/                    # Pipeline working files
  scripts/
    pipe.sh
    parser.sh
    briefer.sh
    translate.sh
    ...
  templates/
    ...
```

## Success Metric

1. **Faithfulness to the source.**
2. **Consistency across hundreds of chapters.**
3. **Machine-readable human corrections.**
4. **Low-cost specialized models doing specialized jobs.**
5. **Institutional memory that improves the pipeline over time.**

Chapter 500 should use the same terminology, character voices, relationships, and style conventions established in chapter 5.
