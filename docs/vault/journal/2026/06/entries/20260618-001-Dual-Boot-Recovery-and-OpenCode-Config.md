---
type: work-entry
id: 20260618-001
date: 2026-06-18
status: completed
confidence: medium
projects: []
daily:
  - "[[2026-06-18]]"
systems: []
scripts: []
files:
  - dotfiles/docs/vault/changelog-raw.md
tags:
  - backfill
modified: 2026-06-28
---

# 20260618-001 -- Dual-Boot Recovery and OpenCode Config

## Goal

Recover dual-boot after CachyOS breakage and configure OpenCode/OpenClaw.

## Problem

CachyOS boot broke after update. Dual-boot Limine/GRUB configuration was undocumented. OpenCode/OpenClaw needed local model provider config.

## Resolution

Fixed Limine boot with MX Linux fallback. Configured Hermes 20B on P40 at 13 t/s as local provider. Set up CUDA_VISIBLE_DEVICES=1 isolation. Installed PromptEnhancer-32B in Forge Neo. Applied Python 3.13 fixes for Forge. Exported 70MB ChatGPT with 121 conversations.

## Decisions

CUDA_VISIBLE_DEVICES is the only reliable GPU isolation method in llama.cpp. Python version compatibility is the most common failure point for Forge.
