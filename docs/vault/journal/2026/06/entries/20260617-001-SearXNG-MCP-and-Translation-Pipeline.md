---
type: work-entry
id: 20260617-001
date: 2026-06-17
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-17]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260617-001 -- SearXNG MCP and Translation Pipeline

## Goal

Deploy SearXNG as MCP server and create translation pipeline architecture.

## Problem

No self-hosted search infrastructure. Translation workflow was manual and inconsistent.

## Resolution

Installed SearXNG on LXC 108 with MCP server integration. Created 10-role translation pipeline (parser, glossary, briefer, translator, editor, script-checks, style-auditor, consistency-checker, verifier, continuity-updater). Added OpenCode MCP docs.

## Decisions

Multi-role pipeline distributes cognitive load -- each role has a narrow, verifiable scope.
