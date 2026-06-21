# Stop AI Agent Hallucinations — Reference

**URL:** https://dev.to/aws/stop-ai-agent-hallucinations-4-essential-techniques-2i94
**Series:** https://dev.to/elizabethfuentes12/series/36052 (7 parts)
**Author:** Elizabeth Fuentes L (AWS)
**Repo:** https://github.com/aws-samples/sample-why-agents-fail

## 4 Techniques

1. **Graph-RAG** — Cypher queries on Neo4j instead of vector chunk search. Exact aggregations, no statistical fabrication.
2. **Semantic Tool Selection** — FAISS filter 31 tools down to top-3 per query. 89% token reduction, 86% fewer errors.
3. **Neurosymbolic Guardrails** — Strands Agents hooks enforce rules at framework level, not prompt level. LLM cannot bypass.
4. **Multi-Agent Validation** — Executor → Validator → Critic swarm cross-checks results before output.

## Key Papers Referenced

- MetaRAG (2025) — Hallucination detection: https://arxiv.org/pdf/2509.09360
- Internal Representations (2025) — Tool selection: https://arxiv.org/abs/2601.05214
- RAG-KG-IL (2025) — Hybrid framework: https://arxiv.org/pdf/2503.13514
- Teaming LLMs (2025) — Multi-agent: https://arxiv.org/pdf/2510.19507

## Framework

All demos use [Strands Agents](https://strandsagents.com) with Amazon Bedrock (swappable to OpenAI/Anthropic/Ollama).
