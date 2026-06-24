# Memory → Reasoning → Execution Pipeline

How `vault-query | llama-loader` closes the loop.

## The Command

```bash
vault-query gpu_mode persistence | llama-loader
```

Two stages: vault memory retrieval → reasoning engine.

## Stage 1: vault-query

Searches the vault and returns structured memory:

```
[DECISION] NP_ARG stored as value not CLI flag
[DECISION] gpu_mode added to persistent state

[KNOWLEDGE] state system should never store CLI flags
[KNOWLEDGE] GPU mode affects splitter + ngl selection

[CONVERSATION] fix discussion about last.sh GPU_ARG removal
```

"Give me everything you know about this topic from memory."

## Stage 2: llama-loader reasoning

Accepts stdin as an "external context bundle" — a structured reasoning input, not raw text.

### Step 1 — Parse input

Classifies by type:
- DECISIONS → highest priority constraints
- KNOWLEDGE → system rules
- CONVERSATION → supporting context

### Step 2 — Convert to execution context

```yaml
context:
  decisions:
    - gpu_mode must persist in state layer
    - CLI flags must not be stored
  knowledge:
    - state system stores values, not flags
    - GPU mode influences ngl + split
  history:
    - last.sh bug caused redundant GPU_ARG
query_intent:
  implied: "how should gpu_mode be handled in current design?"
```

### Step 3 — Feed into planner

```
model_profile + hardware + context_bundle → execution_plan
```

Output:

```yaml
execution_plan:
  gpu_mode: "persist in state layer only"
  cli_behavior: "derive at compile time"
  ngl_adjustment: true
  split_strategy: dynamic
```

### Step 4 — Optional action layer

Propose a fix, generate a patch, or print a recommended config.

## The Mental Model

| Component | Role |
|-----------|------|
| vault-query | memory retrieval |
| pipe (`\|`) | context injection |
| llama-loader | reasoning + planning engine |

```
memory → reasoning → execution
```

## What This Actually Means

You are not asking the system a question. You are feeding it relevant memory so it can decide what the correct system behavior should be.

**Before:** user remembers bug → manually fixes script

**After:** vault retrieves bug history → llama-loader understands system rules → generates correct configuration or fix automatically

## The Real Implication

This line:

```bash
vault-query gpu_mode persistence | llama-loader
```

is a primitive version of "context injection into a reasoning compiler" — which is exactly what the v2 execution planner is becoming.

## Upgrade Path

Current: unstructured text piping.

Target: structured JSON output.

```bash
vault-query --json gpu_mode persistence
```

```json
{
  "decisions": [...],
  "knowledge": [...],
  "conversations": [...]
}
```

That is where this becomes reliable automation, not just clever scripting.

## Next Components (Not Yet Built)

- `vault-query --json` — structured JSON output for planner injection
- Planner v2 input spec — direct ingestion format for llama-loader
- Full memory → plan → patch generator loop
