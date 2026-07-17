---
tags: [project, active, local-ai, architecture, implementation]
status: active
created: 2026-06-24
updated: 2026-06-24
---

# Local AI Control Tower — Concrete Architecture Spec v1

A self-hosted AI stack acting as: technical secretary for homelab/workstation/projects, retrieval layer over vault/configs/scripts/logs/docs, controlled drafting engine, and narrow automation layer — all local, reproducible, one-click rebuildable.

See also: [[local-ai-strategy]] for higher-level strategy and use-case priorities; [[ai-bubble-watchboard]] for market context.

---

## 0. Purpose

The Control Tower is:

- a **technical secretary** for your homelab, workstation, and projects
- a **retrieval layer** over your Obsidian vault, configs, scripts, logs, and docs
- a **controlled drafting engine** for commands, configs, and technical notes
- a **narrow automation layer** for summarization, indexing, and document cleanup
- a **monitoring point** for local models and AI infrastructure, without cloud subscriptions

It is **not**:

- a general autonomous agent
- a "replace all software with chat" platform
- a multi-tenant enterprise product
- a fragile Rube Goldberg machine of ten AI services

---

## 1. Design Goals

### 1.1 Primary

The system must:

- run **locally**
- use **GGUF-capable local inference**
- support **retrieval over your own data**
- be **rebuildable from scripts**
- preserve clear boundaries between inference, retrieval/indexing, UI/chat, automations, and storage
- remain useful even if AI hype collapses tomorrow

### 1.2 Functional Goals — v1 Workflows

**[[core-baseline]] Workflow A: Ask My Vault**
- "What did I decide about Quartz in the last rebuild notes?"
- "Show me every note related to OPNsense + WireGuard + DNS"
- "What was the storage layout I settled on for Akuma?"

**[[core-baseline]] Workflow B: Explain This Config / Log / Error**
- Paste a `docker-compose.yml`, systemd unit, nginx config, `journalctl` output, or Proxmox config
- Get explanation, probable failure point, suggested next steps, markdown note summary

**[[core-baseline]] Workflow C: Draft Technical Artifacts**
- Generate fish scripts, rewrite notes into clean procedures, draft [[QUICK-START]] plans / architecture docs / bootstrap notes, produce config change summaries

**[[core-baseline]] Workflow D: Ingest External Technical Docs Into Vault**
- README → cleaned markdown note; forum guide → summarized note with tags; PDF → extract, summarize, store

---

## 2. Environment Assumptions

**Host:** Akuma (CachyOS Linux, fish shell)
**Primary AI preference:** local inference, GGUF, llama.cpp
**Likely UI/tooling:** Open WebUI / AnythingLLM, OpenClaw
**User home:** `/home/ken`

### Known storage preferences

| Path | Purpose |
|------|---------|
| `/home/ken/.local` | Local AI tooling |
| `/media/storage/ai/ollama/models` | Ollama model storage (bind-mounted to `~/.ollama/models`) |
| `/home/ken/.openclaw/workspace` | OpenClaw workspace |

The Control Tower is a **workstation-local control plane** — not the same thing as the Quartz server, homepage container, or public wiki stack.

---

## 3. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    LOCAL AI CONTROL TOWER                    │
│                        Host: Akuma                          │
├──────────────────────────────────────────────────────────────┤
│  1. Inference Layer                                         │
│     llama.cpp server(s) / optional Ollama sidecar          │
│                                                              │
│  2. Orchestration / UI Layer                                │
│     Open WebUI or AnythingLLM, optional OpenClaw / TUI      │
│                                                              │
│  3. Retrieval Layer                                         │
│     vault indexer + embeddings + vector store / metadata    │
│                                                              │
│  4. Automation Layer                                        │
│     ingest scripts, note transformers, summarizers          │
│                                                              │
│  5. Data Sources                                            │
│     Obsidian vault, homelab docs / markdown / scripts       │
│                                                              │
│  6. Output Targets                                          │
│     vault notes, summaries, architecture docs, drafts       │
└──────────────────────────────────────────────────────────────┘
```

The stack splits into **five planes**:

| Plane | Role |
|-------|------|
| A — Inference | Runs local LLMs, exposes to rest of stack |
| B — Control / UI | Human-facing access |
| C — Retrieval / Knowledge | Queryable local knowledge from notes/configs/scripts |
| D — Automation | Narrow, boring, useful jobs |
| E — Storage | Predictable locations for models, indexes, app data, outputs |

---

## 4. Plane A: Inference

**Primary backend: `llama.cpp`** — matches GGUF-first workflow, custom template control, reproducibility, local model experimentation.
**Optional sidecar: Ollama** — convenience layer only, not [[core-baseline]] authority.

### Canonical rule

All [[core-baseline]] models must be runnable through `llama.cpp` first. Use Ollama only if a frontend requires it, a specific model is easier there, or you want a quick known-good alternate route.

### Service layout

| Port | Purpose |
|------|---------|
| `8081` | Primary local model API (bind `127.0.0.1` only) |
| `8082` | Alternate coding model |
| `8083` | Summarization / long-context model |
| `11434` | Ollama, if retained |

### Role-based model slots

| Slot | Role | Requirements |
|------|------|-------------|
| 1 — General technical assistant | Linux help, config explanation, note summarization, command drafting, architecture docs | Good instruction following, long context, strong technical reasoning, stable markdown |
| 2 — Coding / script model | Fish scripts, shell debugging, config generation, YAML/JSON editing | Stronger coding bias, better structured output, less verbosity |
| 3 — Retrieval / long-context synthesis | Answering from vault chunks, summarizing many notes | Long context, reliable summarization, not overly creative |
| 4 — Lightweight fast utility | Note cleanup, title/tag suggestion, short summaries, batch processing | Low memory, fast enough for scripts |

### Routing (no auto-router in v1)

| Task | Slot |
|------|------|
| Ask vault / summarize notes | Slot 3 |
| Explain config / logs | Slot 1 |
| Draft fish / shell / config | Slot 2 |
| Batch note cleanup / tag suggestion | Slot 4 |
| Architecture doc drafting | Slot 1 or Slot 3 |

---

## 5. Plane B: Control / UI

**Primary UI:** Open WebUI *or* AnythingLLM
**Secondary client:** OpenClaw or terminal/TUI

| Priority | Pick |
|----------|------|
| Vault + document retrieval | AnythingLLM |
| General local model interaction + flexible UI | Open WebUI |
| Scriptable / keyboard-heavy | OpenClaw as side client |

**Primary web UI:** bind `127.0.0.1:3000` locally; reverse-proxy later for LAN if wanted.

---

## 6. Plane C: Retrieval / Knowledge

The most important plane. **The system should answer from your corpus first, then use the model to synthesize.**

### Data sources — indexing tiers

| Tier | Sources |
|------|---------|
| **Tier 1 (v1)** | Obsidian vault, project markdown/architecture docs, shell/fish scripts/compose files, selected config dirs, [[QUICK-START]]/troubleshooting notes |
| **Tier 2** | Exported logs/incident notes, README/GitHub docs imported into vault, PDF manuals/forum guides → markdown |
| **Tier 3** | Full raw system logs, giant codebases, random downloads |

### Canonical data roots

```
/home/ken/Documents/ObsidianVault       # canonical notes
/home/ken/.openclaw/workspace           # AI workspace / drafts
/home/ken/projects                      # selected repos or docs
/home/ken/docs                          # imported technical docs
/home/ken/homelab-configs               # exported configs / compose / infra
```

### Indexing policy

**Include:** `.md`, `.txt`, `.yaml`, `.yml`, `.json`, `.toml`, `.ini`, `.service`, `.conf`, `.fish`, `.sh`, `.py`, selected README-like files.

**Exclude:** media binaries, model files, `.git`, `node_modules`, package caches, VM images, giant logs, browser profiles, secrets dirs, encrypted keys, random downloads.

### Chunking

- **Markdown:** by file → heading hierarchy → paragraph blocks under headings
- **Code/config:** by file → section/block; keep file path and block name in metadata

**Required metadata per chunk:** source path, file name, note title, top-level heading, tags (if parseable), modified timestamp, content type (`note`, `config`, `script`, `doc`, `log-summary`).

### Retrieval modes

| Mode | Use |
|------|-----|
| Semantic | "find notes related to WireGuard DNS" |
| Keyword + semantic hybrid | Exact product/service/model/file/branch names |
| Scoped | "only search vault" / "only search configs" / "only search [[QUICK-START]] notes" |

---

## 7. Plane D: Automation

Deterministic-first with LLM assistance — not "agents everywhere."

### v1 approved jobs

| Job | Input | Output |
|-----|-------|--------|
| Vault ingest transformer | Markdown/README/guide/raw notes | Cleaned markdown, title, summary, tags, optional next actions |
| Log/config summarizer | Pasted logs or config files | Plain-English explanation, probable issues, recommended next steps, optional vault note stub |
| Monthly project summary | Selected vault folders/workspaces | Summary of [[changelog]], unresolved items, recurring topics, cleanup candidates |
| AI bubble watchboard updater | Collected notes/news snippets | Cleaned monthly watchboard note |

### Explicitly banned in v1

Autonomous shell execution, autonomous infra modification, agents with direct write access to critical configs, self-triggering "optimize my homelab" loops, broad browser-automation agents, email/calendar/credential-driven "assistant" automation.

---

## 8. Plane E: Storage

Separate **large/static**, **indexed knowledge**, and **generated working data**.

### Directory layout

```
/home/ken/.local/share/local-ai/
├── apps/
│   ├── open-webui/
│   ├── anythingllm/
│   └── control-tower/
├── config/
│   ├── profiles/
│   ├── prompts/
│   └── routing/
├── data/
│   ├── indexes/
│   │   ├── vault/
│   │   ├── docs/
│   │   └── configs/
│   ├── embeddings/
│   ├── ingest-cache/
│   └── reports/
├── logs/
│   ├── ingestion/
│   ├── model/
│   └── jobs/
└── scripts/
    ├── ingest/
    ├── index/
    ├── reports/
    └── maintenance/
```

### Models (on larger storage)

```
/media/storage/ai/
├── models/
│   ├── gguf/
│   └── ollama/
├── cache/
└── exports/
```

---

## 9. Security Model

Local trusted-user system, not public service. Rules:

- UI not publicly exposed by default — bind local-first
- Exclude sensitive paths from indexing: SSH/GPG private keys, password stores, browser secrets, `.env` secrets (unless intentional), auth tokens
- Separate "readable knowledge" from "dangerous control" — retrieval can read docs/config exports but should not have automatic write access to live infra

---

## 10. Operating Modes

| Mode | Purpose |
|------|---------|
| 1 — Interactive Assistant | Manual Q&A and drafting; model slot + optional retrieval scope |
| 2 — Retrieval | Answer from indexed sources; include source path, file name, section heading, confidence caveat |
| 3 — Batch Job | Narrow jobs on schedule or manually: re-index, summarize imported docs, generate monthly summary, clean raw notes |

---

## 11. v1 Service Inventory

### Required

1. `llama.cpp` primary model service
2. One UI service (Open WebUI or AnythingLLM)
3. Indexing / ingestion scripts
4. Local metadata + index storage
5. Job runner scripts

### Optional

6. Ollama sidecar
7. OpenClaw terminal client
8. Dedicated embeddings service (if UI doesn't handle embeddings cleanly)

---

## 12. Recommended v1 Deployment

**Target:** Akuma directly (not a remote container) — fastest iteration, easiest vault/notes access, simplest model access.

**Form factor:** One compose stack or service bundle for UI + support services; `llama.cpp` separately managed for independent runtime control and easier debugging.

---

## 13. Configuration Files

### `models.yaml`

```yaml
models:
  general:
    backend: llama.cpp
    endpoint: http://127.0.0.1:8081
    role: technical_assistant
  coding:
    backend: llama.cpp
    endpoint: http://127.0.0.1:8082
    role: coding
  retrieval:
    backend: llama.cpp
    endpoint: http://127.0.0.1:8083
    role: long_context_retrieval
  fast:
    backend: llama.cpp
    endpoint: http://127.0.0.1:8084
    role: lightweight_utility
```

### `data-roots.yaml`

```yaml
roots:
  vault:
    path: /path/to/obsidian-vault
    include: [md, txt]
  homelab_configs:
    path: /home/ken/homelab-configs
    include: [md, yml, yaml, json, toml, conf, service, fish, sh]
  docs:
    path: /home/ken/docs
    include: [md, txt, pdf]
```

---

## 14. Workflow Specs

### Workflow 1: Ask My Vault

1. Determine retrieval scope
2. Retrieve relevant chunks from indexed roots
3. Pass chunks + question to retrieval model
4. Produce answer with source references
5. Optionally write a summary note

**Success criteria:** answer project-history questions from own notes, locate past decisions and scripts, tell you *where* it found them.

### Workflow 2: Explain Config / Log

1. Classify input type
2. Optionally retrieve similar notes from vault
3. Send to general technical model
4. Produce stable structure:

```markdown
## What this is
## What looks wrong
## Likely cause
## Suggested next checks
## Commands / edits to consider
## Notes to save in vault
```

### Workflow 3: Convert Rough Notes into Proper Vault Entry

1. Summarize
2. Detect major topics
3. Build headings
4. Produce tags
5. Optionally add unresolved questions / next steps

**Output:** clean markdown note ready for vault.

### Workflow 4: Technical Doc Ingest

1. Normalize formatting
2. Summarize
3. Extract key procedures
4. Mark warnings / assumptions
5. Write vault-ready note

**Output:** cleaned markdown, summary, key commands/steps, source link, tags.

---

## 15. Build Order

### Phase 1 — Foundation

1. Directory structure
2. Primary `llama.cpp` service
3. One UI
4. One indexed vault root
5. One "Ask My Vault" workflow

**Exit criteria:** "What did I write about X?" / "Where is the note about Y?" / "Summarize all notes tagged Z"

### Phase 2 — Config/log analysis

1. Paste-in config analysis
2. Paste-in log analysis
3. Vault note generation from analysis
4. Scoped retrieval from config docs and notes

**Exit criteria:** Paste a config or error → useful structured answer + note stub.

### Phase 3 — Ingest pipeline

1. Docs import folder
2. Normalization scripts
3. Imported-doc indexing
4. Note transformer jobs

**Exit criteria:** Drop in a README or guide → clean vault note.

### Phase 4 — Monthly reporting / maintenance

1. Monthly vault summary job
2. Stale-note finder
3. Project activity summary
4. AI watchboard note updater

---

## 16. Operational Rules

1. If a workflow does not save time weekly, it does not get promoted
2. Every AI-generated artifact that matters must be saveable to the vault
3. Retrieval answers must expose source locations
4. Live infra [[changelog]] require human review
5. The system must remain usable if one frontend is removed — inference backend is separate, data roots are explicit, scripts are not trapped inside a single UI product

---

## 17. What Not to Optimize Early

Don't spend the first month on: prompt libraries with 80 variants, personality routing, multi-agent orchestration, exposing the system to the internet, automatic shell execution, giant benchmark bake-offs.

---

## 18. Minimal v1 Deliverables

**Services:** local llama.cpp model endpoint, one UI connected to it, one index over the vault.

**Files:** `models.yaml`, `data-roots.yaml`, index script, ingest script, monthly summary script.

**Workflows:** Ask My Vault, Explain Config/Log, Convert Rough Notes to Vault Entry.

**Documentation:** one `README-Control-Tower.md`, one rebuild procedure, one directory [[map]].

---

## 19. Suggested First Implementation

**Step 1:** Stand up `llama.cpp` as the stable inference service.

**Step 2:** Pick one primary UI — Open WebUI (broad chat UX) or AnythingLLM (retrieval-first).

**Step 3:** Index the Obsidian vault, one `homelab-configs` folder, one `docs` import folder.

**Step 4:** Implement the three mandatory workflows: Ask My Vault, Explain This Config/Log, Clean These Notes Into a Proper Entry.

**Step 5:** Only after that — imported-doc ingestion, monthly summaries, OpenClaw/alternate clients, second/third model slots.

---

## 20. Concrete v1 Recommendation

| Layer | Choice |
|-------|--------|
| Inference | `llama.cpp` |
| Main UI | Open WebUI |
| Secondary knowledge UI | AnythingLLM (if Open WebUI's knowledge flow feels shallow) |
| Terminal power-client | OpenClaw |
| Source of truth | Obsidian vault |
| Automation | Local fish/Python scripts under `~/.local/share/local-ai/scripts/` |

**First three jobs to build:** [[index]], config/log explainer, rough-note → vault-note transformer.

---

## Related

- [[local-ai-strategy]] — higher-level strategy, use-case tiers, 90-day plan
- [[ai-bubble-watchboard]] — market monitoring context
- [[software/ai-tools/llama-setup]] — llama.cpp build and GPU layout
- [[software/ai-tools/commands]] — local AI command reference
- [[research/ai-bubble-reality-check]] — bubble thesis and evidence log
