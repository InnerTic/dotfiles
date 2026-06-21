# Index Format + Retrieval System

The routing layer for the vault memory system. Everything else feeds into it.

## Core Index Layout

```
indexes/
  conversation_index.json
  knowledge_index.json
  decision_index.json
```

Optional later: `artifact_index.json`

## Shared Index Entry Schema

Every index entry follows the same shape:

```json
{
  "id": "2026-06-19-llama-loader-v2",
  "title": "llama-loader execution planner design",
  "type": "conversation | knowledge | decision",
  "topics": ["llama-loader", "planner", "state", "gpu"],
  "tags": ["architecture", "bugfix", "design"],
  "date": "2026-06-19",
  "summary": "Shift from preset launcher to model-aware execution planner.",
  "source_path": "conversations/2026/06/19-llama-loader-v2.md",
  "importance": 0.85,
  "links": [
    "decision:2026-06-19-np-state-format",
    "knowledge:execution-planner-core"
  ]
}
```

## Index Semantics

| Index | Content | Purpose |
|-------|---------|---------|
| `conversation_index` | Raw + cleaned discussion traces | Context reconstruction |
| `knowledge_index` | Stable facts extracted from chats | First-class memory |
| `decision_index` | "Why we did X" | Highest value — debugging systems |

## Retrieval Pipeline

### Step 1 — Query Expansion

Input: `gpu_mode persistence bug`

Expanded to:
- gpu_mode
- state persistence
- llama-loader state system
- NP_ARG bug

### Step 2 — Index Scoring

```
score = topic_match × 0.4 + tag_match × 0.2 + summary_similarity × 0.2 + recency_weight × 0.2
```

### Step 3 — Selection Tiers

Always retrieve in layers:
- **Tier 1:** decisions (highest priority)
- **Tier 2:** knowledge (system facts)
- **Tier 3:** conversations (context fill)

### Step 4 — Context Bundle Output

```
[DECISIONS]
- NP_ARG state format fix (2026-06-19)

[KNOWLEDGE]
- State system stores values, not CLI flags

[CONVERSATION SNIPPET]
- discussion of symlink bug in llama-loader entry script
```

This is what gets fed to the model.

## Minimal CLI Search

```bash
vault-search "gpu_mode persistence"
```

Pipeline: grep summaries first, fallback to ripgrep full text, then rank by index metadata. No embeddings required yet.

## Agent System Prompt

```
You are a system agent operating over a structured vault memory system.

You do NOT rely on conversation history.

You MUST retrieve context from:
- decision_index (highest priority)
- knowledge_index (system facts)
- conversation_index (contextual history)

Rules:
1. Always prefer decisions over conversations.
2. If conflicting information exists, decisions override everything.
3. Do not assume missing context. Query the vault indexes.
4. Treat knowledge entries as stable system truths.
5. Treat conversations as historical traces only.

When responding:
- cite relevant decision IDs when applicable
- base system changes only on decision + knowledge entries
- explicitly state when information is missing from vault

Memory retrieval format:
[decision:ID]
[knowledge:ID]
[conversation:ID]

You are not a chat assistant.
You are a maintenance and execution agent for a living system.
```

### Planner-Aware Extension (llama-loader v2)

Before executing any system-level action:
1. Check `decision_index` for prior rationale
2. Check `knowledge_index` for constraints
3. Check execution planner rules (if present)
4. Only then proceed

If no decision exists, propose one instead of acting.

## Full Loop

```
chat → vault ingestion → indexing → retrieval → planner → execution → logs → vault
```

That is a closed system.

## Design Warning

Do NOT retrieve raw full chat dumps by default. This loses determinism, relevance control, and performance.

Always force: index → selection → reconstruction, not dump → prompt stuffing.
