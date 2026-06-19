# Changelog (Raw / Verbose)

## Changelog Policy

- Newest first.
- Recent entries are detailed.
- Older entries are condensed.
- Breaking architectural shifts are marked as milestones.
- Detailed implementation notes belong here.

## 2026-06-19

milestone:
    modular architecture transition — flat script → layered pipeline with modes, state system, GPU config

- **fix(core): `NP_ARG` double-prefix bug (`-np -np 1`)**
  - Root cause: `save_state()` stored `-np 1` (with flag), `concurrency.sh` expected bare `1`
  - Fix: strip `-np` prefix before saving, prepend on load
  - Fixed in `common.sh:184`, `last.sh:53`, `concurrency.sh:5`
- **fix(state): `gpu_mode` never persisted to state**
  - `resolve_default("gpu_mode", "3")` always fell back to `3` because state never saved it
  - Fix: added `gpu_mode` to profile state and `last_gpu_mode` to global state (`common.sh:188,199`)
  - Added `GPU_MODE` load to `last.sh:54` so last-mode preserves GPU mode
- **fix(mode): `last.sh:57` redundant `GPU_ARG="--main-gpu 0"` removed**
- **fix(core): `llama-loader.sh` SCRIPT_DIR resolution broken via symlink**
  - `test-llm` alias → `~/.local/bin/test-llma-loader` → symlink to `llama-loader/llama-loader.sh`
  - `dirname "$0"` resolved to `~/.local/bin/` instead of the real script directory
  - Error: `/home/ken/.local/bin/lib/common.sh: No such file or directory`
  - Fix: changed `dirname "$0"` → `dirname "$(readlink -f "$0")"` in `llama-loader.sh:8`
  - Mode scripts (`modes/*.sh`) unaffected — they are `exec`'d from their real path

- **refactor(cli): symlink reorg for llm / test-llm**
  - `~/.local/bin/llama-loader` → `llama-loader.old` (old flat script, `llm` alias)
  - `~/.local/bin/test-llma-loader` → `llama-loader/llama-loader.sh` (new modular entry)
  - zsh alias `test-llma-loader` renamed to `test-llm` in `.zshrc:14`

- **feat(shell): fish completions for llm and test-llm**
  - Created `~/.config/fish/completions/llm.fish` — port suggestions (8080, 8081, 8082)
  - Created `~/.config/fish/completions/test-llm.fish` — port suggestions (8080, 8081, 8082)
  - Fish auto-loads by command name, no sourcing needed

- **docs(vault): purge CUDA 12.4/gcc9 from Arch context**
  - Split `llama-setup.md` into per-distro: `llama-setup-cachyos.md` (CUDA 12.9) and `llama-setup-debian.md` (CUDA 12.4)
  - `llama-setup.md` → index page linking to both
  - Removed stale CUDA 12.4 references from `gpu-config-notes.md`
  - Extracted temp scratchpad from `docs/2026-06-16.md` (6244 lines → trimmed)
  - Added `yakuake-keyd-f24.md`, `vlm-research.md`, `kvm-bridge-networking.md`

## 2026-06-18

- docs(vault): add dual-boot recovery guide (Limine/MX Linux) and keyboard input reference
- docs(agents): restore Installation Protocol as appendix to AGENTS.md
- docs(agents): trim Arch-specific refs, flatten docs table, shorten sections
- docs(vault): rebuild-notes — add OpenCode/OpenClaw, Hermes, Forge fixes, dual-boot (2026-06-18 session)

## 2026-06-17

- docs(agents): note CUDA 12.4 used by Debian install, fix trailing newline
- docs(agents): add model inventory, vault conventions, GPU formula
- docs(agents): add installation protocol section
- docs(infra): add reference links to searxng-setup doc
- feat(infra): add mcp-searxng server to opencode config, document MCP setup

## 2026-06-16

milestone:
    planning and design phase — pipeline spec, roadmap, JSON orchestration

- feat(infra): install SearXNG (pip venv + user systemd) and document setup
- cleanup(vault): model-index — remove note-to-ai, fix formatting, clarify VRAM notes
- cleanup(core): upgrade script checks to deterministic validation gate
- feat(planning): add pipeline spec, roadmap & JSON orchestration
- docs(planning): add pipeline design proposal as reference

## 2026-06-15

milestone:
    vault foundational restructure — sections, pipeline docs, model index

- refactor(vault): reorg flat docs into sections, fix pipeline model refs, add research wiki & F24 note
- docs(vault): expand pipeline with per-role docs, full model index with evaluations
- docs(vault): fix forge GPU layout, add prompt enhancer project
- docs(vault): add projects section with translation-pipeline and forge
- docs(vault): update todo with completed scripts migration
