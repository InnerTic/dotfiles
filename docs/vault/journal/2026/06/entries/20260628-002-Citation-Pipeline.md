---
type: work-entry
id: 20260628-002
date: 2026-06-28
status: completed
confidence: medium
time_spent: 1h
projects:
  - "[[Citation & Attribution Pipeline]]"
daily:
  - "[[2026-06-28]]"
systems:
  - "[[Qwen3]]"
  - "[[llama-server]]"
scripts:
  - "[[vault-attribution.py]]"
files:
  - ~/.local/bin/vault-attribution.py
  - docs/vault/projects/citation-attribution.md
tags:
  - citation
  - attribution
  - pipeline
  - jaccard
modified: 2026-06-28
---

# 20260628-002 — Citation & Attribution Pipeline

## Goal

Every vault file with external provenance gets a `source:` field in frontmatter.

## Architecture

5-phase CLI pipeline:

```
scan   →   fetch   →   compare   →   apply   →   audit
```

- Scan: inventories all 242 vault files (38 cited, 204 uncited)
- Fetch: downloads source files to `~/.local/share/vault-attribution/sources/`
- Compare: line-level Jaccard similarity (≥90% auto, ≥50% review)
- Apply: writes `source:` to frontmatter of confirmed matches
- Audit: POSTs remaining uncited files to local llama-server for origin guess

## Commands

```bash
vault-attribution.py scan          # list uncited
vault-attribution.py fetch URL     # cache source
vault-attribution.py compare       # similarity scan
vault-attribution.py apply         # add source: fields
vault-attribution.py audit         # AI origin guess
vault-attribution.py status        # pipeline progress
```

## Decisions

**Similarity algorithm:** Jaccard on normalized lines (strip whitespace, lowercase). Intersection / max of both sets. Requires ≥5 significant lines to compare.

**AI audit model:** Qwen3.6-35B via local llama-server at localhost:8080. Sends file content with system prompt requesting origin guess.

## Problems

No source repos have been fetched yet — comparison phase hasn't run. Richemlie/llm-thinkinghats repo appears to be deleted/made private.

## Next

- Clone or identify candidate source repos
- Run `compare` against cached sources
- Review ≥50% similarity matches
- Run AI audit on remaining uncited files

## References

- [[Citation & Attribution Pipeline]]
- [[vault-attribution.py]]
