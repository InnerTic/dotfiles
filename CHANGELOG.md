# Changelog (Curated)

## Changelog Policy

- Newest first.
- Recent entries are detailed.
- Older entries are condensed.
- Breaking architectural shifts are marked as milestones.
- Detailed implementation notes belong in Raw Changelog.

## 2026-06-19

milestone:
    modular architecture transition — flat script → layered pipeline with modes, state system, GPU config

- fix(core): `NP_ARG` double-prefix (`-np -np 1`) — strip flag before save, prepend on load
- fix(state): `gpu_mode` never persisted to state — added to profile + global state
- fix(mode): `last.sh` redundant `GPU_ARG` removed, GPU_MODE now loaded from state
- refactor(cli): symlink reorg — `llm` → `llama-loader.old`, `test-llm` → modular entry
- feat(shell): fish completions for `llm` and `test-llm` (port suggestions)
- docs(vault): purge CUDA 12.4/gcc9 from Arch context, split llama-setup per-distro
- docs(vault): add yakuake-keyd-f24, vlm-research, kvm-bridge-networking

## 2026-06-18

- docs(vault): dual-boot recovery, keyboard input reference
- docs(agents): trim Arch-specific refs, flatten docs table

## 2026-06-17

- docs(agents): model inventory, vault conventions, GPU formula
- docs(infra): SearXNG MCP server setup

## 2026-06-16

milestone:
    planning and design phase — pipeline spec, roadmap, JSON orchestration

- feat(infra): SearXNG install + docs
- feat(planning): pipeline spec, roadmap, JSON orchestration
- cleanup(vault): model-index formatting, validation gates

## 2026-06-15

milestone:
    vault foundational restructure — sections, pipeline docs, model index

- refactor(vault): restructure flat docs into sections
- docs(vault): add translation-pipeline, forge, prompt enhancer projects
