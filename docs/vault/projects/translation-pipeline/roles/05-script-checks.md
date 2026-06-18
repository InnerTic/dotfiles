# Step 5 — Script Checks (Deterministic Validation Gate)

**No GPU required** | **Non-AI deterministic validation** (grep/awk/jq/sed/sort/uniq)

## Role

This stage is a **non-AI validation gate** that runs on the *edited translation output* before any semantic or continuity processing.

It is designed to catch **mechanical corruption, encoding drift, and structural inconsistencies** that LLMs routinely fail to detect or normalize incorrectly.

> This stage is intentionally non-probabilistic.
> No model involvement. No interpretation. No heuristics.

It operates on **normalized UTF-8 text only**, ensuring consistent comparisons across all chunks.

## System Guarantees

- No GPU required
- No ML inference
- Fully deterministic execution
- Zero semantic interpretation allowed
- Failures are binary (pass/fail per check)
- Output is machine-parseable for downstream gating

## Normalization Layer (pre-check)

All text is normalized before validation:

- smart quotes → ASCII quotes
- em dashes / en dashes → hyphens
- full-width spaces → standard spaces
- Unicode NFC normalization
- removal of invisible formatting artifacts

```bash
sed 's/[“”]/"/g; s/[‘’]/'"'"'/g; s/[—–]/-/g; s/[　]/ /g'
```

## Validation Rules

### 1. Quote Integrity

Detect unbalanced quotation marks.

```bash
grep -o '"' | wc -l   # must be even
grep -o "'" | wc -l   # must be even
```

**Failure condition:** odd count → unresolved quote closure

### 2. Bracket / Dialogue Integrity

Ensures dialogue structure is preserved.

```bash
grep -o '「' | wc -l
grep -o '」' | wc -l
```

**Failure condition:** mismatch in counts

### 3. Script Leakage Detection

Ensures no untranslated source language remains.

#### Japanese (JP pipelines)

```bash
grep -oP '[一-龯ぁ-んァ-ン]'
```

#### Chinese (JP/EN pipelines where CN should not remain)

```bash
grep -oP '[\u4e00-\u9fff]'
```

**Failure condition:** any match detected

### 4. Structural Markdown Integrity

Detects broken formatting.

```bash
grep -c '```'
```

**Failure condition:** odd count (unclosed block)

### 5. Paragraph Stability

Detects duplication or corruption.

```bash
sort | uniq -d
```

**Failure condition:** repeated paragraph detected

### 6. Entity Drift Detection (Names)

Detects inconsistent naming variants.

```bash
grep -oE 'Alice|Alicia|アリス' | sort | uniq -c
```

**Failure condition:** multiple competing variants present

### 7. Whitespace Integrity

Detects formatting instability.

Checks:

- trailing whitespace
- mixed tabs/spaces
- inconsistent indentation

```bash
grep -P '\s+$'
```

### 8. Sentence Duplication Detection

Detects repeated lines (copy-paste or model loop errors).

```bash
sort | uniq -d
```

### 9. Glossary Enforcement (optional extension)

Ensures expected terminology frequency consistency.

Example pattern:

- required term appears ≥ N times
- forbidden variants appear 0 times

### 10. Dialogue Ratio Sanity Check (heuristic-lite)

Not semantic analysis — purely structural ratio validation:

- count of `" "` or `「」` lines vs total lines

Used to detect:

- collapsed dialogue sections
- accidental narration expansion

## Output Contract

This stage produces:

```json
{
  "status": "PASS | FAIL",
  "failures": [
    {
      "check": "JAPANESE_LEAKAGE",
      "severity": "HIGH",
      "location": "line 128",
      "evidence": "残った文字列"
    }
  ],
  "metrics": {
    "quotes": 42,
    "brackets": 42,
    "paragraphs": 18
  }
}
```

## Failure Semantics

| Result | Meaning | Action |
| ------ | ------- | ------ |
| PASS | structurally clean | proceed to consistency checker |
| FAIL | mechanical corruption detected | block pipeline + retry or escalate |

## Pipeline Position

```
Translator → Editor → Script Checks → (gate) → Consistency Checker
```

If FAIL:

```
Editor output is invalidated
→ re-run editor or translator depending on failure type
```

## Design Intent

This stage is not about correctness of meaning.

It is about ensuring:

> "The text is structurally safe to even be interpreted by higher reasoning systems."

It acts as a **compiler lexer phase for natural language output**.

## Alternatives

N/A — deterministic. Could be extended with additional checks but there's no model competition for this role.
