# Phase 0 — Inventory & Mapping Report

**Date:** 2026-06-21
**Agent:** opencode/big-pickle
**Status:** COMPLETE — no files moved, no [[changelog]] made

## Summary

| Classification | Count | Scope |
|---|---|---|
| **VAULT** | 178 | docs/, docs/vault/ — knowledge, Quartz, architecture docs, runbooks, audits, prompt hats, changelogs |
| **DOTFILES** | 35 | shell/, ssh/, git/, bootstrap*.sh, [[AGENTS]].md, .gitignore, README.md, scripts/bootstrap/ (user env modules) |
| **INFRA** | 37 | scripts/ (Proxmox/LXC, GPU inference, system [[health]], toggle scripts), scripts/llama-loader/ (full system), scripts/lxc/ (container components) |
| **UNKNOWN** | 0 | — |
| **TOTAL** | 250 | — |

## Repo Boundary Definitions

### vault.git — Knowledge + Quartz source
- `docs/` (entire directory tree): INDEX.md, .obsidian/, vault/
- `CHANGELOG.md`, `CHANGELOG.raw.md`, `KEY_LOCATIONS.txt`

**178 files total.**

### dotfiles.git — Shell + UI environment
- `shell/`: .bashrc, .zshrc, config.fish, .profile, [[fastfetch]].jsonc
- `ssh/config`
- `git/.gitconfig`
- `bootstrap.sh`, `bootstrap-arch.sh`, `bootstrap-debian.sh`, `bootstrap-container.sh`, `bootstrap-proxmox.sh`, `bootstrap-server.sh`
- `scripts/bootstrap/` (full tree): lib/, modules/ (shell/git/ssh/[[fastfetch]]/tmux/sudo/containers), per-distro profiles
- `AGENTS.md`, `README.md`, `.gitignore`, `scripts/test-cleanup-backups.sh`, `scripts/link-workspace.sh`, `scripts/toggle-p40.example.yaml`

**35 files total.**

### infra.git — Proxmox + automation + bootstrap
- `scripts/build-gold-lxc.sh`
- `scripts/check-fixes.sh`
- `scripts/forge-start.sh`
- `scripts/healthcheck.sh`
- `scripts/live-env-setup.sh`
- `scripts/llama-loader*` / `scripts/llama-loader/` (full tree, 19 files)
- `scripts/llama-loader.old`
- `scripts/llama-server.sh`
- `scripts/lxc-bootstrap.sh`
- `scripts/lxc-provision.sh`
- `scripts/lxc/` (full tree: [[core-baseline]].sh, fonts.sh, fish.sh, zsh.sh, aliases.sh)
- `scripts/toggle-gpu-profile.sh`
- `scripts/toggle-p40.sh`

**37 files total.**

## Notes for Resume

- Phase 0 complete — no files were moved or modified
- All classifications have confidence ≥85 (no UNKNOWN)
- `docs/vault/scripts/` contains documented copies of scripts (classified as VAULT — they are knowledge copies, not the live executables)
- The live scripts are in `scripts/` (classified as INFRA or DOTFILES depending on purpose)
- Next: Phase 1 — generate destination paths and risk-level plan
