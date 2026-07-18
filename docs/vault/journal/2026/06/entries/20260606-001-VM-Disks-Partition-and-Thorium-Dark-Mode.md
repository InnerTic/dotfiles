---
type: work-entry
id: 20260606-001
date: 2026-06-06
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-06]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260606-001 -- VM-Disks Partition and Thorium Dark Mode

## Goal

Repartition sde for VM storage and fix Thorium shell dark mode.

## Problem

sde layout was outdated. Thorium browser had no dark mode in shell mode.

## Resolution

Updated sde to 50/50 split (sde1 ext4, sde2 xfs). Added --force-dark-mode to Thorium shell. Created AKUMA_VERSIONS.md V1.

## Decisions

AKUMA_VERSIONS.md foundation -- first system-wide version tracking.
