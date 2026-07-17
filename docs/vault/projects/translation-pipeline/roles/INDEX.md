# Translation Pipeline v2.0 — Role Index

Japanese & Chinese web novel translation pipeline across two GPUs.

## GPU Layout

| GPU | Roles | Capacity |
|-----|-------|----------|
| **RTX 3060 (12GB)** | Parser, Editor, Style Auditor | Models ≤~9GB file |
| **Tesla P40 (24GB)** | [[glossary]], Briefer, Translator, Consistency, Verifier, Continuity | Models up to ~20GB |

> **VRAM note:** MoE models load ALL expert weights in llama.cpp — file size ≈ VRAM usage. A 14GB MoE model needs ~14GB VRAM, not "active params."

---

## Stages

### [[00-parser]] — Parser
`text-to-cypher-Gemma-3-4B-Instruct-2025.04.0.f16.gguf` — 3060
Break text into explicit structural info: characters, speakers, locations, scenes, POV, time shifts. Does NOT translate.

### [[01-glossary-updater]] — Glossary Candidate
`gemma-4-26B-A4B-APEX-Compact.gguf` — P40
Discover new [[glossary]] (names, titles, skills, magic, cultivation [[glossary]]). Append-only to `glossary-candidate.md`.

### [[02-briefer]] — Narrative Briefer
`DS4X8R1L3.1` — P40
Build context for verification: relationships, timeline, ambiguity anchors, pronoun mappings, translation traps.

### [[03-translator]] — Literal Translator
`Qwen3.6-27B` — P40
Literal Japanese/Chinese→English. Preserve order, [[glossary]], honorifics. No embellishment.

### [[04-editor]] — Editor
`gemma-3-it-12B-Q8_0.gguf` — 3060
`gemma-3-12b-it-vl-polaris-glm-4.7-flash-var-thinking-instruct-heretic-uncensored-q8_0.gguf` — 3060 (experimental, A/B tested)
Polish readability. Grammar, flow, natural English. Never rewrite meaning.

### [[05-script-checks]] — Script Checks
grep/awk/jq — deterministic
Quote balance, bracket balance, remaining CJK, repeated paragraphs, honorific counts.

### [[06-style-auditor]] — Style Auditor
`QiMing-Gemma-3-4b.f16.gguf` — 3060
Check style bible compliance: honorifics, quotes, capitalization, named style rules. Pure specialist.

### [[07-consistency-checker]] — Consistency Checker
`Qwen2.5-Coder-32B` — P40
Compare against project history: terminology drift, speaker attribution, POV drift, timeline.

### [[08-verifier]] — Verifier
`PromptEnhancer-32B` — P40
Final QC: omissions, additions, name errors, drift, continuity violations. Does NOT rewrite.

### [[09-continuity-updater]] — Continuity Updater
`gemma-4-26B-A4B-APEX-Compact.gguf` — P40
Update canon: equipment, injuries, deaths, relationships, locations, scene index, timeline.

---

## Pipeline Flow

```
Raw Text → Parser → Glossary → Briefer → Translator → Editor → Script Checks
  → Style Auditor → Consistency → Verifier → Continuity → Human Review → Output
```

---

## Notes / Adjustments
`AI read the following and update the dotfiles with the new info`


`# 🧠 Translation Pipeline — Model Layer v2 (Updated)

This system is designed for:

- Japanese web novels → English
- Chinese web novels → English (secondary path)
- future manga OCR + translation expansion

It is structured as a **multi-tier cognition stack**:

> large models = reasoning + truth  
> mid models = translation + editing  
> small models = structure + enforcement

---

# 🧩 CORE MODEL GROUPS

## 1. Primary Translator Layer (High Fidelity)

### A) Qwen3.6-27B-Q4_K_M (GPU: P40)

**Role:** Deep Translator / Gold Standard

This remains the **highest-quality general translation engine**.

### Why it stays

- strongest reasoning among your local models
- handles ambiguity, missing subjects, context drift
- stable across long web novel chapters
- best for:
    - metaphor-heavy prose
    - unreliable narration
    - multi-character scenes

### Weakness

- slower
- slightly “editorializes” if not constrained

### Use when:

- difficulty = Medium/High
- continuity-sensitive chapters
- unclear speakers or pronouns
- emotional ambiguity scenes

---

## B) gemma-3-JP-EN-Translator-v1-4B (NEW CORE FAST PATH)

**Role:** Fast Translator / Draft Engine (Primary throughput layer)

### What it is

A **specialized JP→EN translation model trained directly on parallel fiction data**:

- web novels
- dialogue-heavy content
- structured JP storytelling corpora
- ShareGPT-filtered bilingual datasets

This is not a general LLM.

It is:

> a sentence-level translation compressor for fiction

---

### Why it is important in your system

This model enables:

### 🚀 High throughput translation

- 2–5× faster than 27B path
- good enough for most “standard” web novel chapters

### 🧾 Structural consistency

- more literal sentence mapping than Qwen
- less paraphrasing drift than general models

### 🔧 Pipeline compression

It allows collapsing:

```
JP → Parser → Qwen → Editor → Verifier
```

into:

```
JP → 4B Translator → Editor → Verifier
```

for low/medium difficulty chunks.

---

### Strength profile

|Capability|Rating|
|---|---|
|Literal translation|★★★★★|
|Dialogue handling|★★★★|
|Honorific retention|★★★★|
|Deep inference|★★|
|Continuity reasoning|★★|

---

### Weaknesses (critical)

- weak global narrative reasoning
- will normalize ambiguity (danger)
- cannot maintain multi-chapter logic
- may flatten stylistic nuance

---

### Correct usage

Use ONLY for:

- sentence-level translation
- fast draft generation
- bulk chapter processing

Do NOT use for:

- final authority translation
- continuity resolution
- character logic inference

---


---

## 3. Editor Layer (English Naturalization)

### Floppa-12B-Gemma3-Uncensored

**Role:** English Editor / Flow Smoother

### Function

- improves readability
- fixes awkward literal translation
- preserves meaning strictly
- does NOT add content

### Critical constraint

This layer is where drift risk exists.

Must be audited downstream.

---

## 4. Verification Layer (Truth System)

### PromptEnhancer-32B + DS4X8R1L3 Verifier (P40)

**Role:** Ground Truth Validator

### Function

- compares:
    - original JP
    - translation
    - [[glossary]]
    - character database
    - briefer context

### Detects:

- omission/addition errors
- honorific drift
- name inconsistencies
- continuity violations
- tense mismatch
- speaker misattribution

### Output rule

> NEVER rewrite — only report issues

---

## 5. Consistency Layer (Cross-Chapter Memory)

### Qwen2.5-Coder-32B

**Role:** Continuity Auditor

### Function

- compares chunk N against N-1 / N-5 / N-9 / N-14
- detects drift patterns:
    - terminology [[changelog]]
    - relationship evolution errors
    - repeated or lost narrative states

---

## 6. Micro-Control Layer (NEW DESIGN)

This is where your **new Gemma 4B models sit**

---

# 🧪 MICRO-MODEL SYSTEM (UPDATED)

## A) JMingo E4B (JP Parser)

Already defined above.

### Position:

```
Stage 0 → Structural decomposition
```

---

## B) QiMing-Gemma-3-4B (Rule Auditor)

**Role:** Style + Rule Enforcement Gate

### Function

- validates editor output
- enforces style bible
- checks [[glossary]] compliance
- blocks silent paraphrase drift

### Output:

```
RESULT: PASS / FAILVIOLATIONS:- Honorific dropped- Glossary mismatch- Dialogue format errorSEVERITY: HIGH/MED/LOW
```

---

## C) NEW: gemma-3-JP-EN-Translator-v1-4B

### Role: Fast Translator (Primary throughput engine)

This is now your:

> DEFAULT translation engine for “normal difficulty” chunks

---

## ⚙️ PIPELINE ARCHITECTURE (FINAL)

### FULL ACCURACY PATH

```
JP RAW → JMingo Parser → Qwen 27B Translator → Floppa Editor → QiMing Auditor → Verifier (32B) → Consistency Checker → Output
```

---

### FAST PATH (NEW DEFAULT FOR MOST CHAPTERS)

```
JP RAW → gemma 4B JP-EN Translator → Floppa Editor → QiMing Auditor → Verifier (optional gating) → Output
```

---

### HYBRID ESCALATION PATH

```
JP RAW → gemma 4B Translator → QiMing FAIL?      → escalate to Qwen 27B      → re-translate only flagged sections
```

---

# 🧠 SYSTEM BEHAVIOR SHIFT (IMPORTANT)

You are no longer building a “pipeline”.

You are building:

> a **tiered translation engine with escalation logic**

---

# 🔑 DESIGN INSIGHT

## Old design (inefficient)

- every chunk uses full heavy stack
- high GPU cost
- slow throughput

## New design (adaptive)

- 4B handles 60–80% workload
- 27B only handles “hard reasoning segments”
- micro-models enforce structure cheaply
- large models only resolve ambiguity

---

# ⚙️ RECOMMENDED FINAL ROLE MAP

|Layer|Model|Purpose|
|---|---|---|
|Parser|JMingo E4B|JP structure extraction|
|Fast Translator|Gemma 4B JP-EN|bulk translation|
|Gold Translator|Qwen 27B|difficult reasoning|
|Editor|Floppa 12B|readability|
|Auditor|QiMing 4B|rule enforcement|
|Verifier|32B DS4X8|truth checking|
|Consistency|Qwen 32B coder|long-term memory|

---

# 🧾 FINAL NOTE

This update introduces a key optimization:

> you are no longer bottlenecked on 27B translation

Instead:

- 27B becomes an exception handler
- 4B becomes the default engine
- verification remains heavy but selective
added notes 
# Model Drop-In: Mistral Editor (Stable)

## Model

```
mistral-7b-instruct-v0.2.Q8_0.gguf
```

---

## Role Name

```
Surface Editor (Strict)
```

---

## Pipeline Position

```
Stage: Editor Layer (Post-Translation)
```

---

## Primary Purpose

Light English surface correction only.

Acts as a **syntax stabilizer**, not a rewriter.

---

## Core Function

- Fix grammar and punctuation
- Improve readability minimally
- Normalize awkward literal translation output
- Preserve original meaning exactly

---

## Hard Constraints (NON-NEGOTIABLE)

This model must NEVER:

- change meaning
- infer missing context
- add explanations
- merge sentences for stylistic reasons
- remove ambiguity present in source
- alter dialogue intent
- rewrite tone or narrative voice

---

## Must Preserve

- Names (exact spelling)
- Honorifics (senpai, sama, etc.)
- [[glossary]] [[glossary]] (exact match required)
- Sentence order unless grammatically invalid
- Dialogue structure (quotes, breaks)

---

## Input Contract

```
<translated chunk text>
```

Optional:

```
style-bible.md (read-only reference)glossary-approved.md (read-only reference)
```

---

## Output Contract

```
<edited text>EDIT LOG:- grammar fixes: yes/no- sentence merges: yes/no (only if required)- tone change: none- ambiguity preserved: yes
```

---

## Failure Modes (WATCH LIST)

If this model:

- paraphrases meaning → FAIL
- improves narrative clarity beyond grammar → FAIL
- removes ambiguity → FAIL
- compresses dialogue into prose → FAIL

---

## Recommended Sampling Settings

```
temperature: 0.1top_p: 0.9repeat_penalty: 1.1context: 4096–8192
```

---

## Role Intent Summary (for agent routing)

```
This model is a deterministic English surface transformer.It is not a translator, not a reviewer, and not a storyteller.Its job is to clean structure without touching semantics.
```

- Below is a **machine-routable JSON spec** for your full translation system. It is designed so an external agent can:

- select models automatically
    
- route chunks by difficulty
    
- enforce role constraints
    
- trigger escalation (4B → 27B → verifier)
    
- keep strict separation between translation / editing / verification
    

No narrative fluff. This is structured as a control plane definition.

---

# 🧠 Translation Pipeline — Machine Spec v1

```json
{
  "pipeline_name": "jp_cn_webnovel_translation_engine",
  "version": "1.0",

  "global_rules": {
    "chunk_size_tokens": {
      "min": 1500,
      "max": 3000
    },
    "hard_constraints": [
      "no_model_is_allowed_to_rewrite_meaning",
      "honorifics_must_be_preserved_exact",
      "glossary_terms_must_match_exactly",
      "verifier_has_final_authority",
      "script_checks_are_deterministic_only"
    ],
    "data_flow": "linear_with_optional_escalation"
  },

  "models": {
    "parser_jp": {
      "model": "JMingo/gemma-4-E4B-it-Japanese-GGUF",
      "role": "jp_structural_parser",
      "gpu": "CUDA0",
      "port": 8081,
      "temperature": 0.1,
      "output_contract": "scene_structure_json"
    },

    "translator_fast": {
      "model": "gemma-3-JP-EN-Translator-v1-4B",
      "role": "fast_translation_engine",
      "gpu": "CUDA0",
      "port": 8083,
      "temperature": 0.2,
      "use_case": "low_to_medium_difficulty"
    },

    "translator_gold": {
      "model": "Qwen3.6-27B-Q4_K_M.gguf",
      "role": "high_fidelity_translation_engine",
      "gpu": "CUDA1",
      "port": 8083,
      "temperature": 0.3,
      "use_case": "medium_to_high_difficulty"
    },

    "editor_strict": {
      "model": "mistral-7b-instruct-v0.2.Q8_0.gguf",
      "role": "surface_editor_strict",
      "gpu": "CUDA0",
      "port": 8084,
      "temperature": 0.1,
      "constraints": [
        "no_paraphrasing",
        "no_meaning_change",
        "no_sentence_merging_unless_grammatically_required"
      ]
    },

    "editor_polish_optional": {
      "model": "zephyr-7b-beta.Q8_0.gguf",
      "role": "fluency_polish_layer",
      "gpu": "CUDA0",
      "port": 8084,
      "temperature": 0.2,
      "use_case": "low_risk_output_only",
      "constraints": [
        "no_meaning_change",
        "no_addition_of_context"
      ]
    },

    "auditor_style": {
      "model": "mradermacher/QiMing-Gemma-3-4b-GGUF",
      "role": "style_and_glossary_enforcer",
      "gpu": "CUDA0",
      "port": 8085,
      "temperature": 0.1,
      "output_contract": "pass_fail_violation_report"
    },

    "verifier_truth": {
      "model": "PromptEnhancer-32B.i1-Q4_K_M.gguf",
      "role": "semantic_verifier",
      "gpu": "CUDA1",
      "port": 8086,
      "temperature": 0.2,
      "output_contract": "issue_list_with_severity"
    },

    "consistency_checker": {
      "model": "Qwen2.5-Coder-32B-Instruct-abliterated-Rombo-TIES-v1.0.i1-Q4_K_M.gguf",
      "role": "cross_chunk_consistency_checker",
      "gpu": "CUDA1",
      "port": 8087,
      "temperature": 0.2,
      "context_window": 4,
      "input": "chunk_n_minus_1_to_n_minus_14"
    }
  },

  "routing_rules": {
    "difficulty_assessment": {
      "inputs": [
        "parser_output",
        "lexical_complexity",
        "dialogue_density",
        "ambiguity_flags"
      ],

      "levels": {
        "low": {
          "use_translator": "translator_fast",
          "skip_parser": false,
          "skip_consistency": true
        },

        "medium": {
          "use_translator": "translator_fast",
          "fallback": "translator_gold",
          "enable_auditor": true
        },

        "high": {
          "use_translator": "translator_gold",
          "enable_parser": true,
          "enable_consistency": true
        }
      }
    },

    "escalation_rules": {
      "trigger_conditions": [
        "parser_flags_ambiguity_high",
        "auditor_fail_high_severity",
        "verifier_detects_omission_or_addition",
        "consistency_drift_detected"
      ],

      "action": "retranslate_with_gold_model"
    }
  },

  "pipeline_stages": [
    {
      "id": 1,
      "name": "parser",
      "enabled": true,
      "input": "raw_jp_text",
      "output": "scene_structure",
      "model": "parser_jp"
    },

    {
      "id": 2,
      "name": "translation",
      "input": "raw_jp_text + optional_parser",
      "output": "english_translation",
      "routing": "difficulty_based"
    },

    {
      "id": 3,
      "name": "editor",
      "input": "translation",
      "output": "edited_translation",
      "model": "editor_strict"
    },

    {
      "id": 4,
      "name": "optional_polish",
      "input": "edited_translation",
      "output": "polished_translation",
      "condition": "auditor_pass_low_risk",
      "model": "editor_polish_optional"
    },

    {
      "id": 5,
      "name": "script_checks",
      "type": "deterministic",
      "tools": ["grep", "awk", "jq"],
      "output": "validation_report"
    },

    {
      "id": 6,
      "name": "auditor",
      "input": "edited_or_polished_translation",
      "output": "rule_violation_report",
      "model": "auditor_style"
    },

    {
      "id": 7,
      "name": "consistency_checker",
      "input": "chunk_n_history + current_chunk",
      "output": "drift_report",
      "condition": "high_risk_or_script_fail",
      "model": "consistency_checker"
    },

    {
      "id": 8,
      "name": "verifier",
      "input": "original + translation + parser + auditor + consistency",
      "output": "final_issue_report",
      "model": "verifier_truth"
    },

    {
      "id": 9,
      "name": "continuity_update",
      "input": "approved_chunk + verifier_report",
      "output": "characters_diff + scene_index_update",
      "model": "light_gemma_or_rule_engine"
    }
  ],

  "output_contracts": {
    "translation": {
      "required_fields": [
        "translated_text",
        "difficulty_level",
        "ambiguity_flags"
      ]
    },

    "editor": {
      "required_fields": [
        "edited_text",
        "edit_log"
      ]
    },

    "auditor": {
      "required_fields": [
        "pass_fail",
        "violations",
        "severity"
      ]
    },

    "verifier": {
      "required_fields": [
        "issues",
        "severity_levels",
        "continuity_checks"
      ]
    }
  },

  "state_tracking": {
    "character_db": "characters.md",
    "glossary": {
      "approved": "glossary-approved.md",
      "candidate": "glossary-candidate.md"
    },
    "history": "chunk_indexed_log"
  }
}
```

---

# 🧠 What this gives you (important)

This spec turns your system into:

## 1. A routing engine

Not a pipeline of scripts, but a **decision system**

## 2. A controlled failure system

Instead of random drift:

- low → fast path
    
- medium → hybrid path
    
- high → full reasoning stack
    

## 3. A separation of cognition layers

|Layer|Function|
|---|---|
|4B models|structure + speed|
|7B models|surface transformation|
|27B models|reasoning + translation|
|32B models|truth + consistency|

---

# 🧩 If you want next step

I can extend this into:


- `


*Last updated:* 2026-06-17
