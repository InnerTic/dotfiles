# Proposal: Multi-Stage Machine Translation Pipeline for Japanese & Chinese Web Novels

## 1. Overview

This project builds a **deterministic, multi-model translation system** for converting Japanese and Chinese web novels (and later manga text) into high-quality English.

The system is designed as a **layered processing pipeline**, where each stage performs a narrow, well-defined transformation. Outputs are validated, logged, and only committed if they pass multiple independent checks.

The [[core-baseline]] goal is not just translation quality, but:

> **controlled meaning preservation with traceable transformations across every step**

---

## 2. Design Philosophy

The system is built around four principles:

### 2.1 Separation of concerns

Each model performs a single role:

- understanding
- translation
- surface editing
- verification
- consistency checking

No model is allowed to do everything.

---

### 2.2 Multi-pass validation

Every chunk is processed by multiple independent systems:

- deterministic script checks
- translation model
- editor model
- verifier model
- cross-chunk consistency checker

This reduces single-model failure risk.

---

### 2.3 Meaning stability over fluency

Priority order:

1. semantic accuracy
2. continuity consistency
3. structural correctness
4. readability

Fluency is explicitly *not allowed to override meaning*.

---

### 2.4 Full auditability

Every stage produces logs:

- inputs
- outputs
- model identity
- detected issues
- decisions made

Each chunk becomes a fully replayable record.

---

## 3. System Architecture

Each novel is processed in fixed-size chunks:

```
Japanese/Chinese Source Text
        ↓
Glossary Extraction Layer
        ↓
Context Briefing Layer
        ↓
Translation Layer
        ↓
Editor Layer (surface refinement)
        ↓
Deterministic Script Checks
        ↓
Consistency Checker (cross-chunk)
        ↓
Verifier Layer (semantic audit)
        ↓
Continuity Updater
        ↓
Human Review Gate
        ↓
Final Output + Logs
```

---

## 4. Processing Stages

### 4.1 Glossary Extraction

**Purpose:** Build and maintain translation consistency.

- Extracts:
  - names
  - locations
  - organizations
  - recurring [[glossary]]
- Outputs candidate [[glossary]] entries only
- Requires human approval before becoming authoritative

---

### 4.2 Context Briefing (Briefer)

**Purpose:** Build structured understanding of the text.

- identifies:
  - characters present
  - relationships
  - timeline shifts
  - ambiguity points
- does NOT translate text

This acts as a guide for downstream verification.

---

### 4.3 Translation Layer

**Primary task:** Literal translation with [[glossary]] enforcement.

Two-tier routing:

- Fast model (4B–12B): low/medium difficulty chunks
- Large model (27B+): complex or ambiguous chunks

Rules:

- preserve honorifics exactly
- enforce [[glossary]] [[glossary]]
- no interpretation beyond literal meaning

Outputs include a difficulty assessment.

---

### 4.4 Editor Layer

**Purpose:** English surface correction only.

- fixes grammar and readability
- preserves meaning exactly
- no rewriting allowed

This layer is intentionally constrained to prevent semantic drift.

---

### 4.5 Deterministic Script Checks (Validation Gate)

Non-AI validation stage:

- bracket balancing
- quote balancing
- Japanese character leakage detection
- repetition detection
- formatting validation

Acts as a first-line failure detector.

---

### 4.6 Consistency Checker

Compares current chunk against prior chunks:

- terminology drift
- speaker attribution consistency
- repeated meaning detection
- paragraph ordering issues

Ensures long-term narrative stability.

---

### 4.7 Verifier Layer

Most important semantic audit stage.

Compares:

- original text
- translation
- [[glossary]]
- context briefing
- character database

Detects:

- omissions
- hallucinations
- name errors
- honorific drift
- continuity violations

Outputs structured issue reports with severity levels.

---

### 4.8 Continuity Updater

After approval:

- updates character state database
- tracks:
  - injuries
  - relationships
  - locations
  - possessions
- updates scene index

Maintains story world consistency over time.

---

### 4.9 Human Review Gate

Humans approve or reject:

- translation
- verifier issues
- [[glossary]] updates

Corrections are structured for machine ingestion.

---

## 5. Glossary System

Two-tier structure:

- `glossary-approved.md` — authoritative translation [[glossary]]
- `glossary-candidate.md` — newly discovered [[glossary]] awaiting review

Includes full history tracking of [[changelog]].

---

## 6. Logging and Audit System

Every chunk generates a complete execution trace:

### Stored per chunk:

- model inputs
- outputs at each stage
- verification results
- detected issues
- final decision status

### Purpose:

- debugging translation errors
- tracing hallucination sources
- comparing model performance
- replaying any stage of processing

Each chunk becomes a **reconstructable event log**.

---

## 7. Failure Handling Model

Instead of letting errors propagate, the system uses:

### 7.1 Early detection

- script checks
- consistency drift detection

### 7.2 Containment

- semantic lock stage (optional enhancement)
- verifier gating

### 7.3 Quarantine routing

If hallucination is detected:

- chunk is reprocessed through higher-tier model
- downstream stages are blocked until resolution

---

## 8. Data Integrity Model

Two parallel representations are maintained:

- **Literal translation (truth anchor)**
- **Edited translation (presentation layer)**

Verifier always checks against literal translation to prevent drift from becoming normalized.

---

## 9. System Outputs

For each chunk:

- final English translation
- [[glossary]] updates
- continuity diffs
- full verification report
- execution logs (pass-by-pass)

---

## 10. Intended Outcome

The system is designed to achieve:

- consistent long-form novel translation
- minimal semantic drift over thousands of chunks
- traceable correction history
- reproducible outputs across model runs
- scalable addition of new models and roles

---

## 11. Summary

This is not a simple translation pipeline.

It is a:

> **multi-model semantic processing system with verification, logging, and controlled drift containment**

Its [[core-baseline]] strength is not speed or fluency, but:

- reproducibility
- auditability
- layered error containment
- long-horizon narrative consistency
