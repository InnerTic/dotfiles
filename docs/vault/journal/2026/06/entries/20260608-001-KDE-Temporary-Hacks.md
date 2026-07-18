---
type: work-entry
id: 20260608-001
date: 2026-06-08
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-08]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260608-001 -- KDE Temporary Hacks

## Goal

Document KDE 6 bug 519773 workaround and MIME fix.

## Problem

KDE bug 519773 broke file associations. KIO security dialog blocked .exe double-click.

## Resolution

Documented workaround sequence. Added MIME type fix procedure to temporary-hacks.md.

## Decisions

Some KDE bugs persist across versions -- document even if the fix feels temporary.
