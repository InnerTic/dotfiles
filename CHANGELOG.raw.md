# Changelog (Raw / Verbose)

Detailed record of every change. Newest first. Older entries condensed.

## 2026-06-19

- **fix: `NP_ARG` double-prefix bug (`-np -np 1`)**
  - Root cause: `save_state()` stored `-np 1` (with flag), `concurrency.sh` expected bare `1`
  - Fix: strip `-np` prefix before saving, prepend on load
  - Fixed in `common.sh:184`, `last.sh:53`, `concurrency.sh:5`
- **fix: `gpu_mode` never persisted to state**
  - `resolve_default("gpu_mode", "3")` always fell back to `3` because state never saved it
  - Fix: added `gpu_mode` to profile state and `last_gpu_mode` to global state (`common.sh:188,199`)
  - Added `GPU_MODE` load to `last.sh:54` so last-mode preserves GPU mode
- **fix: `last.sh:57` redundant `GPU_ARG="--main-gpu 0"` removed**
- **fix: `llama-loader.sh` SCRIPT_DIR resolution broken via symlink**
  - `test-llm` alias → `~/.local/bin/test-llma-loader` → symlink to `llama-loader/llama-loader.sh`
  - `dirname "$0"` resolved to `~/.local/bin/` instead of the real script directory
  - Error: `/home/ken/.local/bin/lib/common.sh: No such file or directory`
  - Fix: changed `dirname "$0"` → `dirname "$(readlink -f "$0")"` in `llama-loader.sh:8`
  - Mode scripts (`modes/*.sh`) unaffected — they are `exec`'d from their real path

- **refactor: symlink reorg for llm / test-llm**
  - `~/.local/bin/llama-loader` → `llama-loader.old` (old flat script, `llm` alias)
  - `~/.local/bin/test-llma-loader` → `llama-loader/llama-loader.sh` (new modular entry)
  - zsh alias `test-llma-loader` renamed to `test-llm` in `.zshrc:14`

- **feat: fish completions for llm and test-llm**
  - Created `~/.config/fish/completions/llm.fish` — port suggestions (8080, 8081, 8082)
  - Created `~/.config/fish/completions/test-llm.fish` — port suggestions (8080, 8081, 8082)
  - Fish auto-loads by command name, no sourcing needed

- **docs: purge CUDA 12.4/gcc9 from Arch context**
  - Split `llama-setup.md` into per-distro: `llama-setup-cachyos.md` (CUDA 12.9) and `llama-setup-debian.md` (CUDA 12.4)
  - `llama-setup.md` → index page linking to both
  - Removed stale CUDA 12.4 references from `gpu-config-notes.md`
  - Extracted temp scratchpad from `docs/2026-06-16.md` (6244 lines → trimmed)
  - Added `yakuake-keyd-f24.md`, `vlm-research.md`, `kvm-bridge-networking.md`

## 2026-06-18

- vault: add dual-boot recovery guide (Limine/MX Linux) and keyboard input reference
- restore Installation Protocol as appendix to AGENTS.md
- trim AGENTS.md: remove Arch-specific refs, flatten docs table, shorten sections
- rebuild-notes: add OpenCode/OpenClaw, Hermes, Forge fixes, dual-boot (2026-06-18 session)

## 2026-06-17

- AGENTS.md: note CUDA 12.4 used by Debian install, fix trailing newline
- add model inventory, vault conventions, GPU formula to AGENTS.md
- add installation protocol section to AGENTS.md
- add reference links to searxng-setup doc
- add mcp-searxng server to opencode config, document MCP setup

## 2026-06-16

- install SearXNG (pip venv + user systemd) and document setup
- clean up model-index: remove note-to-ai, fix formatting, clarify VRAM notes
- upgrade script checks to deterministic validation gate
- add pipeline spec, roadmap & JSON orchestration
- add pipeline design proposal as reference

## 2026-06-15

- vault restructure: reorg flat docs into sections, fix pipeline model refs, add research wiki & F24 note
- vault: expand pipeline with per-role docs, full model index with evaluations
- vault: fix forge GPU layout, add prompt enhancer project
- vault: add projects section with translation-pipeline and forge
- vault: update todo with completed scripts migration
