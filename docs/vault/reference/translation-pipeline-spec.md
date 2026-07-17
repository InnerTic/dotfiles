# Multi-Stage Translation Pipeline — System Spec, Roadmap & Orchestration

## 1. One-Page Architecture Spec

### Core

A multi-model, multi-stage translation engine for Japanese/Chinese web novels with strict semantic preservation, full auditability, and controlled drift containment.

### Pipeline Flow

```
RAW TEXT
  ↓
Glossary Extractor (term discovery)
  ↓
Context Briefer (structure + ambiguity map)
  ↓
Translator (literal conversion)
  ↓
Semantic Lock Check (drift detection gate)
  ↓
Editor (surface grammar only)
  ↓
Deterministic Script Checks (Validation Gate)
  ↓
Consistency Checker (cross-chunk drift)
  ↓
Verifier (truth + continuity audit)
  ↓
Continuity Updater (world state tracking)
  ↓
Human Review Gate
  ↓
Final Output + Pass Logs
```

### System Guarantees

- Meaning cannot be overwritten by fluency layers
- Every stage is independently logged
- Drift is detected before propagation
- Editor cannot become a "secondary translator"
- Verifier has override authority
- Outputs are reproducible via pass logs

### Failure Handling

- Early detection: script + semantic lock
- Containment: verifier blocks propagation
- Escalation: re-run with stronger model
- Quarantine: isolate corrupted chunk
- No silent corruption allowed downstream

### Data Artifacts

- `glossary-approved.md`
- `glossary-candidate.md`
- `characters.md`
- `scene-index.md`
- `work/logs/chunk_*/*`

### System Identity

> A deterministic semantic compiler for narrative language

Not a translator chain. A controlled meaning transformation system.

---

## 2. Implementation Roadmap

### Phase 1 — Core Infrastructure

Services (start order matters):

1. [[glossary]] service
2. briefer service
3. translator fast (4B–12B)
4. translator gold (27B)
5. editor (mistral-7b Q8)
6. verifier (32B reasoning model)
7. consistency checker (32B coder model)

### Phase 2 — Pipeline Execution Layer

Scripts:

- `start-server.sh`
- `stop-server.sh`
- `pipe.sh`
- `script-checks.sh`

### Phase 3 — Execution Flow

Chunk lifecycle:

```
load chunk
  → run glossary extraction
  → run briefer
  → route translator (fast or gold)
  → semantic lock check
  → editor pass
  → deterministic checks
  → consistency check (conditional)
  → verifier audit
  → continuity update
  → write outputs
  → append logs
```

### Phase 4 — Logging System

Every chunk:

```
work/logs/chunk_ID/
  stage outputs
  model inputs
  model outputs
  summaries
  final manifest.json
```

### Phase 5 — Safety Gates

Triggers:

- Verifier HIGH severity → retranslate
- Script FAIL → skip consistency fast path disabled
- Semantic drift → block editor output
- [[glossary]] conflict → human review required

### Phase 6 — Optimization Layer (optional later)

- caching [[glossary]] embeddings
- token-based routing
- chunk difficulty classifier
- model selection heuristics

---

## 3. Strict JSON Orchestration Spec

```json
{
  "system": "semantic_translation_engine",
  "version": "1.1",

  "execution_mode": "strict_pipeline_with_gates",

  "global_constraints": {
    "preserve_semantics": true,
    "no_cross_stage_meaning_modification": true,
    "require_audit_log": true,
    "verifier_is_authoritative": true
  },

  "stages": {

    "glossary": {
      "model_role": "term_extractor",
      "output": "glossary_candidate",
      "blocking": false
    },

    "briefer": {
      "model_role": "context_analyzer",
      "output": "structured_brief",
      "blocking": false
    },

    "translator": {
      "routing": {
        "low": "fast_4b_12b",
        "medium": "fast_or_gold",
        "high": "gold_27b"
      },
      "output": "literal_translation",
      "blocking": true
    },

    "semantic_lock": {
      "type": "validation_gate",
      "rules": [
        "entity_preservation",
        "speaker_consistency",
        "event_order_integrity"
      ],
      "on_fail": "retranslate",
      "blocking": true
    },

    "editor": {
      "model_role": "surface_corrector",
      "constraints": [
        "no_semantic_change",
        "no_reinterpretation",
        "grammar_only"
      ],
      "output": "edited_translation",
      "blocking": true
    },

    "script_checks": {
      "type": "deterministic",
      "tools": ["grep", "awk", "jq"],
      "on_fail": "flag_for_verifier_escalation",
      "blocking": false
    },

    "consistency_checker": {
      "model_role": "cross_chunk_drift_detector",
      "window": 14,
      "trigger": "script_fail_or_high_risk",
      "output": "drift_report"
    },

    "verifier": {
      "model_role": "semantic_auditor",
      "authority": "final",
      "output": "issue_report",
      "severity_levels": ["LOW", "MEDIUM", "HIGH"],
      "on_high": "force_retranslation"
    },

    "continuity_update": {
      "model_role": "state_updater",
      "outputs": [
        "characters.md_patch",
        "scene_index_patch"
      ]
    }
  },

  "logging": {
    "enabled": true,
    "mode": "full_pass_trace",
    "directory": "work/logs",
    "final_manifest": "pass_FINAL_manifest.json",
    "record_all_stages": true,
    "record_model_inputs": true,
    "record_model_outputs": true
  },

  "routing_logic": {
    "escalation_conditions": [
      "verifier_HIGH",
      "semantic_lock_fail",
      "entity_mismatch",
      "glossary_conflict"
    ],

    "fallback_behavior": "reprocess_with_gold_model"
  }
}
```

## Synthesis

What this defines is no longer a pipeline.

It is:

> a **stateful semantic compilation engine with verification gates and full trace logging**

### Key upgrade

**Before:** Linear transformation chain

**Now:** Gated, logged, re-routable execution graph with failure containment
