# Changelog (Curated)

Newest changes at top, condensed as they age.

## 2026-06-19

- fix: `NP_ARG` double-prefix (`-np -np 1`) — strip flag before save, prepend on load
- fix: `gpu_mode` never persisted to state — added to profile + global state
- fix: `last.sh` redundant `GPU_ARG` line removed, GPU_MODE now loaded from state
- refactor: symlink reorg — `llm` → `llama-loader.old`, `test-llm` → modular entry
- feat: fish completions for `llm` and `test-llm` (port suggestions)
- docs: purge CUDA 12.4/gcc9 from Arch context, split llama-setup per-distro
- docs: add yakuake-keyd-f24, vlm-research, kvm-bridge-networking

## 2026-06-18

- vault: dual-boot recovery, keyboard input reference
- AGENTS.md: trim Arch-specific refs, flatten docs table

## 2026-06-17

- AGENTS.md: model inventory, vault conventions, GPU formula
- docs: SearXNG MCP server setup

## 2026-06-16

- feat: SearXNG install + docs
- feat: pipeline spec, roadmap, JSON orchestration
- cleanup: model-index formatting, validation gates

## 2026-06-15

- vault restructure: sections, pipeline docs, model index
- projects: translation-pipeline, forge, prompt enhancer
