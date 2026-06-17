# Translation Pipeline

**Source:** `/mnt/data/_translation-pipeline/translation-pipeline/`  
**GPU 0:** RTX 3060 12GB (Forge/SDXL + small models)  
**GPU 1:** Tesla P40 24GB (32B models via llama-server)

## Roles

Each stage is documented in detail with model rationale and alternatives in [[translation-pipeline/roles/README\|roles/]].

| # | Role | Model (Current) | GPU | Port | Details |
|---|------|-----------------|-----|------|---------|
| 1 | [[translation-pipeline/roles/01-glossary-updater\|Glossary Updater]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 3060 | 8082 | [[translation-pipeline/roles/01-glossary-updater\|role →]] |
| 2 | [[translation-pipeline/roles/02-briefer\|Briefer (PromptEnhancer)]] | `PromptEnhancer-32B.i1-Q4_K_M.gguf` | P40 | 8081 | [[translation-pipeline/roles/02-briefer\|role →]] |
| 3 | [[translation-pipeline/roles/03-translator\|Translator]] | `Qwen3.6-27B-Q4_K_M.gguf` | P40 | 8083 | [[translation-pipeline/roles/03-translator\|role →]] |
| 4 | [[translation-pipeline/roles/04-editor\|Editor]] | `Floppa-12B-Gemma3-Uncensored.i1-Q4_K_M.gguf` | 3060 | 8084 | [[translation-pipeline/roles/04-editor\|role →]] |
| 5 | [[translation-pipeline/roles/05-script-checks\|Script Checks]] | grep/awk/jq | — | — | [[translation-pipeline/roles/05-script-checks\|role →]] |
| 6 | [[translation-pipeline/roles/06-consistency-checker\|Consistency Checker]] | `Qwen2.5-Coder-32B-Rombo-TIES.i1-Q4_K_M.gguf` | P40 | 8086 | [[translation-pipeline/roles/06-consistency-checker\|role →]] |
| 7 | [[translation-pipeline/roles/07-verifier\|Verifier]] | `DS4X8R1L3.1-Dp-Thnkr-UnC-24B-D_AU-q5_k_m.gguf` | P40 | 8085 | [[translation-pipeline/roles/07-verifier\|role →]] |
| 8 | [[translation-pipeline/roles/08-continuity-updater\|Continuity Updater]] | `gemma-4-26B-A4B-APEX-Compact.gguf` | 3060 | 8088 | [[translation-pipeline/roles/08-continuity-updater\|role →]] |

For comprehensive model evaluation, alternatives, and tradeoffs, see [[translation-pipeline/model-index\|Model Index]].

## Pipeline

```
Chunk (1500-3000 tokens)
    |
    V
[1] Glossary Candidate — Gemma MOE (port 8082)
    Extract new terms, titles, locations, relationships
    Output: glossary-candidate.md additions only
    |
    V
[2] Briefer — Prompt Enhancer (port 8081)
    Extract: characters, locations, relationships,
             prior events, semantic anchors
    Output: structured context summary + Ambiguity Anchors
    |
    V
[3] Translator — Qwen3.6 (port 8083)
    Produce literal translation using approved glossary + candidates
    Output: translation chunk + difficulty assessment
    |
    V
[4] Editor — Floppa (port 8084)
    Improve readability, natural prose
    Preserve: names, terms, meaning, honorifics
    Output: edited chunk + Edit Log
    |
    V
[5] Script Checks — Deterministic only
    grep / awk / jq
    Unicode normalization pass before all checks
    Output: issue list
    |
    V
    Early exit: if no HIGH script issues → skip [6], go to [7]
    |
    V
[6] Consistency Checker — Qwen Coder (port 8086)
    Compare against prior chunks
    Check: terminology drift, speaker attribution,
           dialogue flow, possible duplicated meaning,
           paragraph order
    Flags are advisory unless they contradict Verifier LOW/MEDIUM findings
    Output: issue list with severity
    |
    V
[7] Verifier — Deep Thinker (port 8085)
    Using briefing + semantic anchors from step 2
    Compare: original, translation, glossary, character db
    Report: omissions, additions, name errors,
            honorific drift, tense inconsistency,
            terminology mismatch, continuity violations
    Severity: HIGH / MEDIUM / LOW
    Do NOT rewrite
    Output: issue report only
    |
    V
[8] Continuity Update — Gemma MOE (port 8082)
    Update character state: acquired items, injuries,
    location changes, relationship changes, deaths
    Output: characters.md diff
    |
    V
[9] Human Review
    Review: translation, verifier report, script issues
    Approve / reject / request fix
    Structured corrections only
    |
    V
[10] Glossary Reconciliation — Gemma MOE (port 8082)
    Move approved candidate terms → glossary-approved.md
    Archive to history/ with reason
    Output: glossary diff
    |
    V
[11] Write Output
    Append approved chunk to output/
    Update continuity database
    Update scene index
```

## Key Rules

- **Chunk size: 1500-3000 tokens** — keeps consistency manageable
- **Verifier must not rewrite** — report issues with severity only
- **Script checks are 100% deterministic** — grep/awk/jq, not a model
- **Briefer briefs the Verifier**, not the Translator
- **Translator stays constrained** — literal, with glossary
- **Human corrections are structured** — machine-readable for glossary learning
- **Continuity database tracks character state** across chapters

## Server Lifecycle

Only **one model loads per GPU at a time** (12GB 3060, 24GB P40). The pipeline is sequential by necessity:

1. Kill any previous server on the target GPU
2. Start the server for the current stage
3. Wait for it to load (15-60s depending on model size)
4. Send the API request
5. Kill the server (or leave it if it's the last stage on that GPU)

This is handled automatically by `pipe.sh`. Each `*-start.sh` script is for manual/interactive use only.

## Source of Truth Priority

When contradictions arise across systems, precedence is:

1. **characters.md** — canonical character state
2. **Approved chunks** — final human-approved output
3. **Verifier logs** — vetted issue reports
4. **Raw chunks** — original source

Precedence for audit disagreements:

**Verifier > Consistency Checker > Script Checks**

Consistency Checker flags are advisory unless they contradict Verifier LOW/MEDIUM findings.

## Glossary System

Two files per project:

```
glossary-approved.md    # Finalized, used by Translator
glossary-candidate.md   # Discovered during translation, pending approval
history/
  0001.md               # Each change logged with reason
  0002.md
  ...
```

Candidates do not pollute the approved dictionary until human-confirmed.

### Term Collision Handling

If the same surface form appears with conflicting definitions across projects, use inline disambiguation:

```
# Sky Stone (World A): a magical gem
# Sky Stone (World B): a rank insignia
```

## Difficulty Assessment

Instead of confidence scores:

```
Difficulty: Medium
Reasons:
  - idiom present
  - archaic speech pattern
  - incomplete sentence
  - cultural reference requiring research
```

This is actionable for the human reviewer.

## Verifier Output Format

```
Issue 1:
  Severity: HIGH
  Type: Wrong character
  Original: <source text>
  Translation: <target text>
  Evidence: Character named differently in previous 14 chunks.
  Suggestion: Revert to consistent name

Issue 2:
  Severity: MEDIUM
  Type: Honorific inconsistency
  Original: <source text>
  Translation: omitted
  Evidence: Style bible says "preserve honorifics"
```

Humans can ignore LOW-priority items.

## Script Checks

Unicode normalization pass runs before all checks — converts smart quotes, em-dashes, and other Unicode variants to their ASCII equivalents so checks are reliable.

Checks against normalized text:

- Quote balance (expect even)
- Bracket balance (expect equal)
- Japanese characters remaining (expect empty)
- Repeated paragraphs
- Name counts per variant
- Markdown code fence balance (expect even)

## Continuity Database

```
characters.md  # per project
```

Tracks per-character: age, equipment, skills, location, status, relationships, injuries.

After every approved chunk, Continuity Updater diffs changes.

## Scene Index Layer

Lightweight narrative segmentation per chunk:

```
scene_id: <project>_<chapter>_<scene>
location: <location>
time: <time>
speakers: <characters>
mood_tag: <tone description>
```

Improves Consistency Checker accuracy, Verifier reasoning, and cross-chunk retrieval.

## Style Bible (per project)

```
honorifics: preserve
thoughts: *
quotes: "
```

## Filesystem

```
/mnt/data/_translation-pipeline/translation-pipeline/
  books/
    <project>/
      raw/                     # Original source text
      glossary-approved.md     # Finalized glossary
      glossary-candidate.md    # Pending terms
      history/                 # Glossary change log
      style-bible.md           # Style bible
      characters.md            # Continuity database
      scene-index.md           # Scene index
      chunks/                  # Tokenized, chunked chapters
      output/                  # Final approved output
      work/                    # Pipeline working files
  scripts/
    pipe.sh                    # Full pipeline orchestrator
    briefer.sh                 # Start briefer server
    translate.sh               # Start translator server
    ...
  templates/
    ...
```

## Scripts

| Command | Action |
|---------|--------|
| `briefer.sh` | Start server for this role (P40, port 8081) |
| `glossary-update.sh` | Start server for this role (3060, port 8082) |
| `translate.sh` | Start server for this role (P40, port 8083) |
| `editor.sh` | Start server for this role (3060, port 8084) |
| `verify.sh` | Start server for this role (P40, port 8085) |
| `consistency-check.sh` | Start server for this role (P40, port 8086) |
| `continuity-update.sh` | Start server for this role (3060, port 8088) |
| `script-checks.sh` | Run deterministic checks (grep/awk/jq) |
| `start-server.sh` | Generic: kill previous server on GPU, start model, wait for ready |
| `stop-server.sh` | Kill server on a given port |
| `pipe.sh` | Run full pipeline on a chunk (auto-manages server lifecycle) |

## See Also

- [[vault/scripts/README\|Scripts]] — llama-server startup, GPU tooling
- [[reinstall-guides/cachyos/forge-neo\|Forge Neo reinstall]] — GPU 0 setup
