---
tags: [project, active, ai-market, monitoring]
status: active
created: 2026-06-24
updated: 2026-06-24
---

# AI Bubble Watchboard

Active monitoring dashboard for AI market bubble dynamics. Not daily news consumption — monthly pulse checks on four signal buckets.

See also: [[research/ai-bubble-reality-check]] for [[core-baseline]] thesis and scenario analysis.

## Four-Panel Framework

Ignore generic "AI news." Watch **leading indicators** only:

---

### Panel 1 — Infrastructure Reality

Tells you whether the money cannon is still firing.

**Hyperscaler capex language** — track earnings/guidance from:

- Microsoft
- Amazon / AWS
- Alphabet / Google Cloud
- Meta
- Oracle

| Signal | Means |
|--------|-------|
| "capacity constrained", "demand exceeds supply" | Still inflating |
| "accelerating AI investment", "expanding datacenter footprint" | Still inflating |
| "optimizing utilization", "pacing deployment" | Cooling |
| "moderating capex growth", "rationalizing buildout" | Cooling |
| "capacity now sufficient", "focus shifting from training to efficiency" | Cooling |

**Memory & GPU supply chain** — track:

- SK hynix, Samsung Electronics, Micron Technology
- NVIDIA
- TSMC
- ASML

| Metric to watch | Why |
|-----------------|-----|
| HBM demand / allocation language | Leading indicator for AI buildout pace |
| DRAM pricing guidance | Broad supply-demand signal |
| Inventory days / channel inventory | Overbuild warning |
| Wafer start / packaging capacity commentary | Supply-side constraint easing |
| Training-led vs inference-led demand | Maturity signal |
| Pre-reservation duration | Commitment depth |

If memory and accelerator demand softens **before** software revenue proves itself, that's one of the cleanest early signs the buildout overshot.

---

### Panel 2 — Enterprise Adoption Reality

"Is anybody actually using this stuff beyond pilot theater?"

Track: McKinsey State of AI, Gartner AI research, Deloitte State of Generative AI, Stanford AI Index.

**Ignore vanity stats** like "X% of companies are using AI." That's almost always a costume.

**Track instead:**

| Metric | What to look for |
|--------|------------------|
| Intensity of use | Weekly/daily users vs total licenses |
| Production vs pilot | Share of teams actually deploying to prod |
| Measured ROI | Cost savings, headcount avoided, ticket deflection, code throughput |
| Retention / renewal | Renewing after 12 months? Expanding seats or cutting? |
| Workflow depth | Embedded in a real workflow, or a chat tab opened twice a month? |

That last question slices through an amazing amount of nonsense.

---

### Panel 3 — Application-Layer Death Watch

The bubble will likely crack here first.

**Startup failure patterns** — signs a company is a wrapper on stilts:

- No moat beyond prompting
- No proprietary workflow integration
- Weak retention
- Pricing based on "seat value" with no measurable savings
- Feature gets copied by the platform incumbents in six weeks

**Pricing compression signals:**

- AI add-on fees rolled into [[core-baseline]] products
- Standalone copilots becoming cheap bundle features
- Vendors forced to justify pricing with actual workflow metrics

**Customer migration from "AI app" to "AI feature":**

A lot of standalone AI products will get eaten by IDEs, ticketing systems, office suites, CRM/ERP/helpdesk platforms, and document management systems.

---

### Panel 4 — Open Model Commoditization

The part that matters most for local AI strategy.

Track: llama.cpp, Ollama, LM Studio, Open WebUI, HuggingFace Open LLM leaderboard, Qwen, Mistral, Meta, Google Gemma.

**Signals to watch:**

- Smaller models getting "good enough" at coding, retrieval, summarization
- Longer context windows becoming practical locally
- Structured output / tool use reliability improving
- Local inference costs dropping relative to cloud subscriptions
- OCR / vision / speech becoming viable in one local stack

If open models keep improving, the value of paid AI wrappers gets kneecapped.

---

## Watchboard Template

Update **once per month** — daily AI news is a brain tax.

### Monthly snapshot — `YYYY-MM-DD`

```markdown
## Infra
- NVIDIA revenue growth:
- Micron / SK hynix / Samsung memory guidance:
- TSMC AI commentary:
- DRAM / HBM / SSD price trend:

## Enterprise
- McKinsey / Gartner / Deloitte findings:
- Earnings-call mentions of actual AI ROI:
- Case studies with numbers (support, coding, search):

## Open models
- Best local coding model:
- Best local summarizer:
- Best long-context model:
- llama.cpp / inference backend changes:
- Quantization quality improvements:

## Wrappers
- Products/features absorbed by incumbents:
- Startups acqui-hired or vanished:
- Categories that stopped making sense as standalone tools:
```

## Related

- [[research/ai-bubble-reality-check]] — [[core-baseline]] thesis, scenarios, evidence log
- [[ai-watchtower]] — the LXC project that implements this monitoring framework
- [[local-ai-strategy]] — what to build locally instead of buying hype
- [[software/ai-tools/commands]] — local AI command reference
