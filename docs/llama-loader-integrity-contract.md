# llama-loader — AI Integrity Repair Contract

## Purpose

The loader previously suffered from:

- CLI flags stored in state (e.g. `-np 1`)
- Double-prefix corruption (`-np -np 1`)
- Weak type boundaries between raw values, runtime CLI flags, and persisted state
- Silent sanitization instead of strict rejection

The system now enforces a strict **3-layer model separation**: configuration → validation → execution.

---

## Core Rules (Non-Negotiable)

### 1. Raw State Rule

State files (`state.json`, `profile.json`) MUST contain:

- primitive values only
- NO CLI syntax
- NO prefixes (`-np`, `--ngl`, etc.)
- NO composite strings

Valid: `"np": "1"`
Invalid: `"np": "-np 1"`, `"np": "--ngl 60"`

### 2. Layer Separation Rule

Every runtime variable follows:

```
A. RAW VALUE (storage-safe)       NP_VAL="1"
B. SANITIZED VALUE (validated)    NP_VAL validated as integer string only
C. CLI DERIVATION (execution)     NP_ARG="-np ${NP_VAL}"
```

CLI strings are NEVER stored.

### 3. Strict Type Enforcement (NP Rule)

NP MUST be integer string only.
Allowed: `"1"`, `"2"`, `"8"`
Forbidden: `"auto"`, `"-np 1"`, `"1.0"`

If invalid: reject immediately, do NOT silently sanitize.

### 4. No CLI in State (Hard Guard)

Before writing ANY state file, reject if value contains: `-np`, `--`, spaces, or non-digit characters. If found: `FATAL: CLI syntax detected in state write attempt`.

### 5. Snapshot Rule

Snapshot output MUST show BOTH raw values and derived CLI form:

```
NP: 1
CLI: -np 1
```

### 6. Runtime Derivation Rule

ALL CLI flags MUST be derived at execution time only:

```
NP_ARG="-np ${NP_VAL}"
NGL_ARG="--ngl ${NGL_VAL}"
```

NEVER store `NP_ARG` in JSON or reuse it from state.

### 7. Safe Default Rule

If state is missing or corrupted, fallback to safe integer defaults. Never propagate raw CLI strings forward. NP fallback = `"1"`.

---

## Required Function Pattern

```bash
validate_int() {
  case "$1" in
    ''|*[!0-9]*)
      echo "FATAL: invalid integer '$1'" >&2
      exit 1
      ;;
    *)
      echo "$1"
      ;;
  esac
}
```

## NP Pipeline (Mandatory Usage)

```bash
NP_RAW=$(resolve_default "np" "1")
NP_VAL=$(validate_int "$NP_RAW")
NP_ARG="-np ${NP_VAL}"
```

---

## Forbidden Patterns (Must Not Exist)

**Storage violations:** `"-np 1"` in JSON, `"np": "-np 1"`

**Runtime violations:** `NP_ARG="-np $(resolve_default ...)"`, `NP_ARG` stored in presets

**Double-prefix bugs:** `-np -np 1`

---

## Error Handling Contract

If CLI syntax is detected anywhere:
- MUST stop execution
- MUST print exact offending value
- MUST refuse to continue

NO fallback sanitization.

---

## Debug Requirement

Every run MUST be able to answer:
1. What is raw NP?
2. What is validated NP?
3. What is CLI NP?

If any cannot be answered cleanly → system is invalid.

---

## Design Intent

This system is not just a launcher. It is a **typed execution planner** with strict separation between configuration, validation, and execution layers.

---

## Optional Hardening

```bash
assert_no_cli_in_state() {
  grep -R "\-np" "$STATE_DIR" && {
    echo "FATAL: CLI contamination detected in state"
    exit 1
  }
}
```

Run at startup and before `save_state`.
