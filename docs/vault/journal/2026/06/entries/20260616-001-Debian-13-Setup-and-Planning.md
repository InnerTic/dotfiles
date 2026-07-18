---
type: work-entry
id: 20260616-001
date: 2026-06-16
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-16]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260616-001 -- Debian 13 Setup and Planning

## Goal

Document Debian 13 installation hoops and plan upcoming infrastructure work.

## Problem

Debian 13 Trixie had numerous installation gotchas (NVIDIA, audio, networking). Multiple projects needed scoping.

## Resolution

Created debian-setup-hoops.md -- comprehensive installation workaround log. Extracted scratchpad content to permanent docs. Scoped SearXNG install, pipeline spec, JSON orchestration.

## Decisions

Installation docs must include the failures, not just the working path.
