---
type: work-entry
id: 20260621-002
date: 2026-06-21
status: completed
confidence: high
projects:
  - "[[Dotfiles]]"
daily:
  - "[[2026-06-21]]"
files:
  - dotfiles/.gitignore
  - dotfiles/AGENTS.md
  - dotfiles/README.md
  - dotfiles/bootstrap.sh
  - dotfiles/bootstrap-arch.sh
  - dotfiles/bootstrap-debian.sh
  - dotfiles/bootstrap-container.sh
  - dotfiles/bootstrap-proxmox.sh
  - dotfiles/bootstrap-server.sh
  - dotfiles/git/.gitconfig
  - dotfiles/scripts/
  - dotfiles/shell/
  - dotfiles/ssh/config
tags:
  - dotfiles
  - reabsorb
  - config
modified: 2026-06-28
---

# 20260621-002 — Dotfiles Reabsorb

## Goal

Establish vault/dotfiles/ as the source of truth for all dotfiles configs and scripts, creating the two-repo architecture with dotfiles.git as a read-only mirror.

## Commits

| Commit | Message |
|--------|---------|
| `2639581` | reabsorb: dotfiles configs + scripts now live in vault/dotfiles/ (source of truth) |

## What was moved

69 files, 3465 lines added:

- **Bootstrap scripts**: `bootstrap.sh`, per-distro variants (arch, debian, container, proxmox, server)
- **Shell configs**: `.bashrc`, `.profile`, `.zshrc`, `config.fish`, `fastfetch.jsonc`
- **Git config**: `.gitconfig`
- **SSH config**: `config`
- **Scripts**: `llama-loader/` (full model management framework), `toggle-p40.sh`, `live-env-setup.sh`, `link-workspace.sh`, `check-fixes.sh`, `healthcheck.sh`, `test-cleanup-backups.sh`, `forge-start.sh`, `llama-server.sh`, `lxc-bootstrap.sh`, `lxc-provision.sh`, `lxc/` utilities
- **AGENTS.md** documenting the two-repo architecture

## Architecture

```
vault.git (source of truth)
  └── dotfiles/  ──sync──►  dotfiles.git (read-only mirror)
```

## References

- [[Dotfiles]]
- [[AGENTS]]
