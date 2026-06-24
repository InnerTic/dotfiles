# Vault Chat Ingestion Architecture

Don't store chats as "logs." Store them as structured memory.

## Core Types

| Type | What it is | Example |
|------|-----------|---------|
| **Episode** | What happened — a chat session summary | `conversations/2026/06/19-llama-loader-v2-planning.md` |
| **Artifact** | What was produced — scripts, configs, schemas | `artifacts/planner-v2-schema.yaml` |
| **Decision** | Why something changed — rationale, impact | `decisions/2026-06-19-np-arg-state-format.md` |
| **Knowledge** | Generalized facts learned from chat | `knowledge/llama-loader/execution-planner.md` |

---

## Vault Structure

```
vault/
  conversations/      raw + cleaned chat episodes
  knowledge/          reusable context (agents read this first)
  decisions/          "why did we do this" — debugging history
  artifacts/          generated outputs (scripts, configs, schemas)
  indexes/            query layer — the brain
```

### conversations/

One file per session, compressed — no greetings, no repetition, preserve technical turns.

```
vault/conversations/
  2026/
    06/
      19-llama-loader-v2-planning.md
```

### knowledge/

Generalized facts extracted from chats. What [[AGENTS]] should actually read first.

```
vault/knowledge/
  llama-loader/
    execution-planner.md
    state-management.md
```

Format:

```yaml
fact:
  Model profiles must be derived, not manually configured.
source:
  conversations/2026/06/19-llama-loader-v2-planning.md
confidence:
  high
```

### decisions/

Every "why did we do this" — saves you from re-solving old [[bugs-and-workarounds]].

```
vault/decisions/
  2026-06-19-np-arg-state-format.md
```

```yaml
decision:
  Store NP as raw integer, not CLI flag string.
reason:
  CLI flags caused double-prefix bugs during reload.
impact:
  fixed persistence inconsistency in state system
related:
  llama-loader state subsystem
```

### artifacts/

Anything that runs or defines structure — scripts, configs, schemas, planner outputs.

```
vault/artifacts/
  planner-v2-schema.yaml
  gpu-model-profile.json
```

### indexes/

The query layer — what the local AI queries first.

```
vault/indexes/
  conversation-index.json
  knowledge-index.json
  decision-index.json
```

```json
{
  "llama-loader": {
    "topics": ["state", "planner", "gpu"],
    "conversations": [...],
    "decisions": [...]
  }
}
```

---

## Retrieval Model

When an agent needs context:

1. **Query index** — "gpu_mode persistence bug", "planner ctx selection logic"
2. **Fetch** — relevant decisions, relevant knowledge, recent conversation excerpts
3. **Assemble context bundle** — `[decision]` + `[knowledge]` + `[recent conversation excerpt]`

Not full chat history.

---

## Chat Ingestion Pipeline

```
raw chat
  ↓
cleaner script (remove noise, greetings, repetition)
  ↓
classified into:
  - conversation (episode)
  - knowledge   (generalized fact)
  - decision    (why something changed)
  - artifact    (something produced)
  ↓
index update
```

Even a simple CLI tool can do this.

---

## Metadata Schema

Every chunk should have:

| Field | Description |
|-------|-------------|
| `id` | unique |
| `type` | conversation, knowledge, decision, artifact |
| `topic` | string |
| `date` | ISO |
| `source` | file path |
| `tags` | [] |
| `summary` | short |
| `embedding_hint` | optional (reserve for later) |

No embeddings needed yet, but design for them.

---

## Key Design Rule

Do NOT store "chat logs as history."

Store "chat logs as transformations into structured memory."

That shift is what makes this usable by [[AGENTS]].

---

## What This Builds Toward

A personal retrieval OS for AI [[AGENTS]] — not just notes, docs, or logs, but a structured cognitive external memory system that supports:

- Debugging old decisions
- Continuing long-running projects
- Rebuilding system state after failure
- Feeding context to both local and remote models
