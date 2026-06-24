---
tags: [project, active, local-ai, architecture]
status: active
created: 2026-06-24
updated: 2026-06-24
---

# Local AI Strategy

Build local AI around **specific tasks with measurable value** — not a fantasy of general autonomy.

See also: [[ai-bubble-watchboard]] for market context; [[research/ai-bubble-reality-check]] for thesis.

## Three-Layer Architecture

### Layer 1 — Core Local Assistant

Purpose: drafting commands, explaining logs, answering config questions, code/shell/YAML/Docker/Proxmox/Linux help, summarizing docs.

**Design rule:** Grounded in your own docs and files, not just a raw chatbot.

Stack: `model + document store + retrieval + file-aware workflow` not `chat UI + vibes`.

### Layer 2 — RAG / Vault / Knowledge Prosthetic

The durable one. Query your vault, preserve half-formed technical thoughts, surface links between projects/commands/decisions/hardware notes.

**Good queries:**

- "show me every note about OPNsense + WireGuard + DNS"
- "what did I decide about Proxmox GPU passthrough?"
- "compare old and current storage layouts"
- "summarize all notes related to Quartz / homepage / vault publishing"
- "what broke last time I tried this"

### Layer 3 — Automations and Narrow Agents

Keep constrained. Use only where AI has a clear job:

- Summarize logs into probable root causes
- Classify notes / tickets / snippets
- Turn rough bullet points into structured docs
- Extract action items from notes
- Produce command drafts with guardrails
- Convert freeform notes into tagged vault entries

**Do not** build an autonomous sysadmin — that road is paved with scorched YAML.

---

## Recommended Stack

### Inference backend

| Engine | When to use |
|--------|-------------|
| **llama.cpp** | Reproducibility, GGUF control, custom templates, squeezing hardware |
| **Ollama** | Fewer moving parts, don't care about internals |

Bias toward **llama.cpp + GGUF** as the real engine, even with a friendlier frontend on top.

### Front-end / orchestration

Choose one that can do document ingestion, chat with citations, model switching, saved workspaces, tool calling:

| Option | Best for |
|--------|----------|
| **Open WebUI** | Personal vault + docs + homelab knowledge |
| **AnythingLLM** | Personal vault + docs + homelab knowledge |
| **LibreChat** | Multi-provider chat, broad UX (less focused on local knowledge base) |

### Retrieval / vault indexing

The piece that makes local AI worth owning.

Requirements:

- Obsidian vault indexed
- Markdown chunking preserving headings/links
- Tags/metadata preserved
- Local embedding model
- Source citations back to file + section

**Golden rule:** The AI should answer from your vault first, not from parametric memory first.

---

## What NOT to Build

| Don't build | Why |
|-------------|-----|
| Giant autonomous agent system | "AI operator that manages the homelab" — not yet |
| Generalized personal AGI shell | Too fuzzy, too many parts, weak ROI |
| Multi-model circus architecture | Don't build a cathedral of adapters until you have one workflow you use weekly |

---

## Use Case Priority

### Tier 1 — Build first

1. **Vault / wiki retrieval assistant** — questions over Obsidian notes, scripts, configs, project docs, install logs
2. **Linux / homelab troubleshooting assistant** — feed journalctl logs, compose files, Proxmox notes, OPNsense/OpenWrt config snippets, shell history
3. **Script drafting / config explanation** — fish scripts, docker compose, service units, config translation

### Tier 2 — Build after that

4. **Document-to-vault ingestion** — PDFs, forum guides, GitHub READMEs cleaned into markdown with tags, summary, action items
5. **Change-log / decision memory** — what changed, why, rollback notes, dependencies

### Tier 3 — Maybe later

6. **Local note triage / weekly review assistant** — summarize unfinished threads, list stale projects, cluster notes, suggest next actions

---

## 90-Day Plan

### Phase 1 — Build the watchboard

Create `ai-bubble-watchboard.md` (done). Update monthly.

### Phase 2 — One local workflow that pays rent

Pick exactly one:

- **Option 1:** "Ask my vault" — index vault, ask questions, get file/section citations
- **Option 2:** "Explain this log/config" — paste logs, get structured diagnosis + next steps
- **Option 3:** "Turn rough notes into proper project docs" — ingest notes, output cleaned markdown

If it doesn't save time weekly, it's a science fair project, not a tool.

### Phase 3 — Add a second workflow only after the first is stable

Progression: Vault Q&A → Config/log explanation → Doc ingestion + summarization → Script drafting → Light automations.

## Related

- [[local-ai-control-tower]] — concrete architecture spec v1 (five-plane stack, build order, config files)
- [[ai-bubble-watchboard]] — market monitoring
- [[software/ai-tools/commands]] — local AI command ref
- [[software/ai-tools/llama-setup]] — llama.cpp build, GPU layout
- [[software/ai-tools/ollama-notes]] — alternative backend
