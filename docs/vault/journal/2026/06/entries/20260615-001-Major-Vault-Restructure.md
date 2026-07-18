---
type: work-entry
id: 20260615-001
date: 2026-06-15
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-15]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260615-001 -- Major Vault Restructure

## Goal

Restructure from flat docs into organized sections with frontmatter and navigation.

## Problem

Flat file structure was unsustainable -- 30+ files with no categorization, no frontmatter, broken wikilinks.

## Resolution

Created deb branch for Debian 13. Reorganized into system/, software/, reference/ sections. Created map.md, faq.md, bugs-and-workarounds.md, dev-setup.md, drives-and-mounts.md. Added YAML frontmatter to all files. Fixed broken wikilinks. Moved .obsidian/ to docs/ root.

## Decisions

Frontmatter metadata transforms a file collection into a knowledge base. Navigation (INDEX + map) makes it usable.
