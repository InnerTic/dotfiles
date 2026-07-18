---
type: work-entry
id: 20260419-001
date: 2026-04-19
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-04-19]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260419-001 -- Storage Layout Overhaul

## Goal

Reorganize disk layout for reliability and separation of concerns.

## Problem

Original CachyOS layout had everything on a single SATA disk with no separation between OS, data, and workspace.

## Resolution

Overhauled to separate volumes: NVMe for workspace, SATA SSD for data, dedicated OS drive. Games moved to /var via bind mount. New layout documented in system-memory.md with UUIDs and fstab entries.

## Decisions

Risk profiles drive layout -- isolate OS from data from workspace. Bind mounts bridge structure without reformatting.
