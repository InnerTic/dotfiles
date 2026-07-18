---
type: work-entry
id: 20260428-001
date: 2026-04-28
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-04-28]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260428-001 -- FixBot GW2 Debugging

## Goal

Debug Guild Wars 2 multi-box setup (ntdll crashes, overlay conflicts, Proton prefixes).

## Problem

Two GW2 instances would crash from ntdll errors and overlay conflicts. 5269-line FixBot chat log accumulated across the session.

## Resolution

Identified NVIDIA GPU forcing requirement, overlay conflicts, and separate Proton prefix needs. Setup documented in gw2-multibox-wine-setup.md. Chat log preserved as reference.

## Decisions

FixBot chat log is too long to summarize but contains all trial-and-error detail. Preserve raw logs alongside distilled docs.
