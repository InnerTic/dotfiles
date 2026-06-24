---
tags: [project, active, lxc, monitoring, ai-market]
status: active
created: 2026-06-24
updated: 2026-06-24
---

# AI Watchtower — LXC Project

A dedicated Proxmox LXC for **market monitoring + source collection + local analysis**. Separate from Quartz — Quartz stays the publishing brain; this is the intelligence/monitoring pipeline.

See also: [[ai-bubble-watchboard]] (monitoring framework this implements); [[local-ai-strategy]]; [[local-ai-control-tower]].

---

## Architecture

```text
Obsidian Vault (source of truth)
    ├─ Quartz LXC
    │   └─ publish selected notes/wiki
    │
    └─ AI Watchtower LXC
        ├─ source collection
        ├─ article capture / feeds / transcripts
        ├─ local analysis / summarization / claim extraction
        ├─ market and hardware watch reports
        └─ markdown export back into the vault
```

**Scope split:** Quartz handles publishing only — no scraping, no ingestion, no market logic. Watchtower handles collection, normalization, analysis, report generation, and vault export.

---

## Project Goals

Track the collapse of hype into reality. Specifically answer:

- what AI demand is **real vs invented**
- whether **hyperscaler capex** is still accelerating or rolling over
- whether **RAM / GPU / SSD pricing** is easing or tightening
- which AI use cases show **measurable ROI**
- which vendors / startups are **wrappers, theater, or collapsing multiples**
- what that means for **local AI strategy** and **hardware-buy timing**

---

## Deployment Constraint

**Build from the gold/base LXC template. Do not repurpose the existing Quartz container.**

Quartz and Watchtower are separate roles in separate containers:

| Container | CT ID (example) | Role |
|---|---|---|
| Quartz publisher | 301 | Quartz build, nginx, web publishing, vault publishing |
| AI Watchtower | 302 | Source collection, analysis, report generation, vault export |

---

## LXC Spec

| Property | Value | Notes |
|----------|-------|-------|
| OS | Ubuntu 24.04 | Unprivileged LXC |
| CPU | 2-4 vCPU | |
| RAM | **8 GB preferred** | 4 GB enough for collectors only; 8 GB if local embeddings or AI helpers |
| Rootfs | 20-40 GB | Depends on article cache depth |
| Nesting | `nesting=1` only if needed | |
| Name | `ai-watchtower` | |

---

## Directory Layout

```
/opt/ai-watchtower/
  app/
    collectors/       # source-specific fetch scripts
    parsers/          # normalize raw -> structured
    analyzers/        # local AI summarization / claim extraction
    reports/          # report generator scripts
    prompts/          # per-task prompt templates
    exporters/        # markdown -> vault output
  config/
    sources.yaml
    models.yaml
    data-roots.yaml
  data/
    raw/              # per-source raw captures
      reuters/
      tomshardware/
      trendforce/
      filings/
      reddit/
      youtube/
    processed/        # parsed/normalized versions
    exports/          # staged markdown ready for vault
    prices/           # price snapshots
    sqlite/           # database files
  logs/
  scripts/            # helper scripts, maintenance
  services/           # systemd service definitions
```

---

## Core Functions

### 1) Source Collection

**Hard evidence:** Reuters, company IR pages, SEC filings / earnings materials, ECB/OECD/government surveys, earnings call transcripts.

**Hardware/supply chain:** Tom's Hardware, TrendForce, ServeTheHome, AnandTech, memory/SSD/GPU price trackers.

**Reality-check:** selected Reddit (field reports + sentiment only), selective YouTube transcripts (interviews/earnings, not influencer noise).

Each collected item stores: source, title, URL, publication date, raw text, capture timestamp, topic tags if known.

### 2) Metadata Storage — SQLite

Tables: `sources`, `articles`, `claims`, `topics`, `watch_events`, `price_snapshots`, `weekly_reports`.

**Articles:** id, source_id, title, url, published_at, captured_at, raw_text_path, summary, evidence_level, topic, tags.

**Claims:** id, article_id, claim_text, claim_type, company, product, region, confidence, direction, notes.

SQLite is enough for a long time and keeps the project rebuildable.

### 3) Local Analysis

Good AI tasks: summarize article into 5-10 bullets, extract claims, identify companies/products/dates, classify evidence level, flag hype vs evidence, compare new claims against prior, draft weekly reports.

**Banned:** autonomous forecasting, deciding truth without sources, replacing human review, giant agentic pipelines before basics work.

### 4) Vault Export

Write markdown into a vault folder:

```
Vault/
  90 Projects/
    AI Watchtower/
      Inbox/
      Weekly Reports/
      Hardware Watch/
      Company Watch/
      Usefulness Ledger/
      Hype Graveyard/
```

Quartz publishes from that structure without needing to know how notes were produced.

---

## Evidence Grading

Every article gets a grade:

| Level | Description |
|-------|-------------|
| **1 — Hard evidence** | Earnings calls, SEC filings, company guidance with concrete numbers, government/institutional survey data, reputable direct reporting with explicit figures |
| **2 — Trade reporting with specifics** | Hardware press with pricing/supply data, industry trackers, detailed interviews with named executives |
| **3 — Vendor claims / marketing** | "Customers are seeing amazing transformation", conference slides without hard numbers, press releases with soft ROI language |
| **4 — Rumor / vibes** | Social media speculation, investor chatter, unsourced claims, low-quality clickbait summaries |

This lets the system distinguish "interesting narrative" from "usable evidence."

---

## Contradiction Tracking

Automatically flag when:

- a new claim contradicts an earlier one
- a claim fails to materialize after a set period
- a hype narrative collides with measured usage or pricing data

Example: vendor says "enterprise adoption surging" vs survey showing very low intensive use → conflict flagged.

---

## Recurring Reports

### Report A — AI Bubble Monitor (weekly)

**Spending side:** Microsoft/Amazon/Google/Meta/Oracle capex guidance, datacenter buildout pace, cloud AI revenue commentary.

**Supply side:** GPU supply, HBM/DRAM/NAND pricing/guidance, Micron/Samsung/SK hynix commentary, packaging/CoWoS constraints.

**Reality side:** ROI studies, enterprise pullback signs, startup failures/consolidation.

**Output:**
```markdown
## Bullish signals
## Bearish signals
## Hype signals
## What changed this week
## What to watch next
```

### Report B — Local AI Hardware Watch

DDR4/DDR5 retail prices, used ECC/server memory, consumer GPU pricing, SSD/NVMe pricing, whether AI demand distorts local build costs.

Answers: "Should I buy RAM this month?", "Is DDR4 still distorted?", "Are local AI GPUs getting saner?"

### Report C — AI Usefulness Ledger

| Use case | User | Why AI helps | Could normal software replace it? | Monetizable? | Confidence |
|---|---|---|---|---|---|
| Code assist | Developers | High | Partial | High | Medium-high |
| Support triage | Support teams | High | Partial | High | High |
| Enterprise search | Office/support/ops | High | Partial | High | High |
| General office copilot | Broad office | Mixed | Often yes | Mixed | Low |
| Autonomous agents | Enterprise workflows | Mixed | Often overhyped | Unclear | Low |

---

## Vault Report Taxonomy

**Main dashboards:** AI Bubble Dashboard, Hardware Price Dashboard, AI Usefulness Ledger, Hyperscaler Capex Watch, Memory and GPU Distortion Watch.

**Company watch notes** (one per company): Microsoft, Amazon, Google, Meta, NVIDIA, AMD, Micron, Samsung, SK hynix, TSMC, OpenAI/Anthropic/model vendors.

**Hype Graveyard:** products that disappeared, AI claims that aged badly, startups that were wrappers and got wiped out, features that turned out to be deterministic software problems wearing an AI hat.

---

## Build Phases

### Phase 1 — Container + ingestion skeleton

LXC creation, directory structure, Python venv, SQLite DB, 3-5 source collectors, one markdown exporter to vault. **Exit:** a weekly report appears in vault automatically.

### Phase 2 — Hardware and market watch

RAM/SSD/GPU price tracking, company watchlist pages, capex watch notes, source tagging. **Exit:** can answer "should I buy RAM now?", "is AI capex story weakening?", "which claims are backed by data?"

### Phase 3 — Local AI structured analysis

Summarization prompts, claim extraction, evidence grading, contradiction detection, report drafting. **Exit:** incoming articles become structured notes instead of a raw archive pile.

### Phase 4 — Quarterly synthesis / anti-hype dashboard

Monthly/quarterly synthesis reports, use-case survival [[map]], vendor reality scorecards, "what got more real / less real" summaries, local AI buying implications.

---

## Service Layout

Simple systemd services and timers:

```
watchtower-collector.service / .timer
watchtower-prices.service / .timer
watchtower-weekly-report.service / .timer
watchtower-export.service
```

All rebuildable from scripts.

---

## Comparison: Control Tower vs Watchtower

| | Control Tower (workstation) | Watchtower (LXC) |
|---|---|---|
| Location | Akuma, bare metal | Proxmox LXC |
| Purpose | Vault RAG, config/log analysis, drafting | Market monitoring, source collection, report generation |
| Users | You (interactive) | Batch/automated |
| AI role | Interactive assistant, retrieval | Structured report generation, claim extraction |
| Output | Answers, drafts, vault notes | Weekly reports, price watches, ledger updates |

---

## What Not to Start With

No vector-database stack, no agent frameworks, no microservice circus, no GPU inference inside the LXC, no autonomous crawling, no orchestration cathedral before the basics exist. First version is: rebuildable, inspectable, low-drama — Python scripts + SQLite + markdown.

---

## Minimal v1 Deliverables

1. Proxmox LXC bootstrap
2. Directory layout
3. Python environment setup
4. SQLite schema
5. Collector scripts for a handful of sources
6. Weekly report generator
7. Vault markdown export
8. systemd services/timers
9. One-command rebuild flow

---

## Related

- [[ai-bubble-watchboard]] — the monitoring framework this implements
- [[local-ai-strategy]] — higher-level local AI direction
- [[local-ai-control-tower]] — workstation-local AI stack, complementary
- [[reference/lxc-build-log]] — precedent LXC build (Quartz 300)
- [[reference/architecture-snapshot]] — homelab network topology
- [[reference/quartz-constitution]] — Quartz design patterns
