---
tags: [research, methodology, ai-evaluation, coding-benchmark]
status: reference
created: 2026-06-24
updated: 2026-06-24
---

# AI Coding Drill Ladder — Skill Isolation Gym

An incremental coding exercise ladder designed to test how well a local AI translates intent → architecture → working code. Each level isolates one software synthesis skill (IO, state, APIs, refactoring, etc.).

See also: [[research/ai-bubble-reality-check]] (macro context), [[projects/ai-watchtower]] (monitoring infrastructure)

---

## Level 1 — Single-File Logic (Pure Function Crafting)

Tests: reasoning, correctness, no dependencies.

### 1. Number System Toy Toolkit

CLI script converting numbers between bases.

1. decimal → binary function
2. extend to base 2–36
3. CLI input parsing
4. invalid digit validation
5. refactor into reusable module

### 2. Text Transformer Engine

Small script transforming text via rules: uppercase/lowercase, reverse, word shuffle, remove vowels.

1. individual transform functions
2. dispatcher (`--mode reverse`)
3. chaining (`--mode reverse,uppercase`)
4. error handling for unknown modes

### 3. Mini Expression Evaluator

Evaluate math strings like `"2 + 3 * 4"`.

1. tokenize
2. shunting-yard or stack eval
3. support `+ - * /`
4. parentheses
5. CLI interface

---

## Level 2 — File IO + State

Tests: persistence, structure, real program behavior.

### 4. JSON Notebook

CLI note app storing JSON: add, list, search, delete.

1. file read/write layer
2. add/list
3. search
4. delete with ID system
5. refactor into classes/modules

### 5. Simple Task Tracker

Minimal TODO: Task model (id, text, done), persist JSON, add/done/list/filter.

### 6. Log File Analyzer

Parse logs (`ERROR: disk full`, `INFO: boot complete`) → count levels, extract top errors, time grouping, CLI flags, export summary JSON.

---

## Level 3 — External Interaction (APIs + OS)

Tests: real-world glue code.

### 7. Weather CLI Tool

Fetch weather from API: mock-first, parse JSON, formatted output, caching, CLI args for city.

### 8. URL Health Checker

Check if sites are up: single request, timeout handling, batch mode, concurrent requests, output report.

### 9. File Watcher Mini Daemon

Watch folder [[changelog]]: detect creation, modification, log events, filter by extension, periodic summary.

---

## Level 4 — Architecture + Modular Design

Tests: system structure, not just scripts.

### 10. Plugin-Based CLI Tool

Command system with [[plugins]]: plugin interface, dynamic loading, command router, error isolation, examples.

### 11. Mini Event System

Pub/sub: event emitter, subscribe/emit, multiple listeners, async events, logging middleware.

### 12. Config-Driven App Loader

YAML/JSON defines app behavior: parse config, [[map]] → runtime objects, validate schema, dynamic execution, hot reload.

---

## Level 5 — AI Stress Tests

Tests: reasoning consistency, regression resistance.

### 13. Refactor Challenge

Give AI messy script → split modules, improve naming, remove duplication, add tests. Measure whether logic breaks.

### 14. Incremental Feature Injection

Start minimal TODO → add persistence, search, tags, export/import. Watch if AI preserves structure.

### 15. Bug Injection Arena

Give working code with off-by-one, race condition, file corruption. Ask AI to detect, explain, patch minimally.

---

## Research Loop Methodology

1. Prompt AI for step 1 only
2. Evaluate output
3. Ask for next incremental change
4. Introduce constraint or failure
5. Measure: coherence, architecture stability, regression resistance, refactor safety

## Possible Evolutions

- Local AI coding benchmark harness
- Prompt-to-code scoring system
- Multi-model comparison suite (GGUF vs cloud)
- Continuous software evolution sandbox
