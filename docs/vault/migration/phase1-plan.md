# Phase 1 — Dry Run Plan

**Date:** 2026-06-21
**Status:** PLAN ONLY — no files moved

## Batch Groupings

### Batch A: VAULT → vault.git (LOW risk, 178 files)

All files under `docs/` preserve their relative structure:

| Source (in dotfiles.git) | Destination (vault.git) | Risk |
|---|---|---|
| `docs/INDEX.md` | `INDEX.md` | LOW |
| `docs/.gitignore` | `.gitignore` | LOW |
| `docs/.obsidian/**/*` | `.obsidian/**/*` | LOW |
| `docs/vault/**/*` | `vault/**/*` (preserve tree) | LOW |
| `CHANGELOG.md` | `CHANGELOG.md` | LOW |
| `CHANGELOG.raw.md` | `CHANGELOG.raw.md` | LOW |
| `KEY_LOCATIONS.txt` | `KEY_LOCATIONS.txt` | LOW |

**Dependencies:** None. Vault files are self-contained markdown.
**Cross-references:** Some vault `.md` files reference `scripts/` paths — these become cross-repo links to `infra.git` or `dotfiles.git`. See Batch D.

### Batch B: DOTFILES → dotfiles.git (LOW risk, 35 files)

| Source | Destination | Risk |
|---|---|---|
| `shell/.bashrc` | `shell/.bashrc` | LOW |
| `shell/.zshrc` | `shell/.zshrc` | LOW |
| `shell/config.fish` | `shell/config.fish` | LOW |
| `shell/.profile` | `shell/.profile` | LOW |
| `shell/fastfetch.jsonc` | `shell/fastfetch.jsonc` | LOW |
| `ssh/config` | `ssh/config` | LOW |
| `git/.gitconfig` | `git/.gitconfig` | LOW |
| `bootstrap.sh` | `bootstrap.sh` | LOW |
| `bootstrap-arch.sh` | `bootstrap-arch.sh` | LOW |
| `bootstrap-debian.sh` | `bootstrap-debian.sh` | LOW |
| `bootstrap-container.sh` | `bootstrap-container.sh` | LOW |
| `bootstrap-proxmox.sh` | `bootstrap-proxmox.sh` | LOW |
| `bootstrap-server.sh` | `bootstrap-server.sh` | LOW |
| `scripts/bootstrap/bootstrap.sh` | `scripts/bootstrap/bootstrap.sh` | LOW |
| `scripts/bootstrap/cachyos.sh` | `scripts/bootstrap/cachyos.sh` | LOW |
| `scripts/bootstrap/debian.sh` | `scripts/bootstrap/debian.sh` | LOW |
| `scripts/bootstrap/container.sh` | `scripts/bootstrap/container.sh` | LOW |
| `scripts/bootstrap/proxmox.sh` | `scripts/bootstrap/proxmox.sh` | LOW |
| `scripts/bootstrap/server.sh` | `scripts/bootstrap/server.sh` | LOW |
| `scripts/bootstrap/lib/common.sh` | `scripts/bootstrap/lib/common.sh` | LOW |
| `scripts/bootstrap/lib/runner.sh` | `scripts/bootstrap/lib/runner.sh` | LOW |
| `scripts/bootstrap/modules/10-sudo-lecture.sh` | `scripts/bootstrap/modules/10-sudo-lecture.sh` | LOW |
| `scripts/bootstrap/modules/12-containers.sh` | `scripts/bootstrap/modules/12-containers.sh` | LOW |
| `scripts/bootstrap/modules/20-shell.sh` | `scripts/bootstrap/modules/20-shell.sh` | LOW |
| `scripts/bootstrap/modules/30-git.sh` | `scripts/bootstrap/modules/30-git.sh` | LOW |
| `scripts/bootstrap/modules/40-fastfetch.sh` | `scripts/bootstrap/modules/40-fastfetch.sh` | LOW |
| `scripts/bootstrap/modules/50-tmux.sh` | `scripts/bootstrap/modules/50-tmux.sh` | LOW |
| `scripts/bootstrap/modules/60-ssh.sh` | `scripts/bootstrap/modules/60-ssh.sh` | LOW |
| `scripts/link-workspace.sh` | `scripts/link-workspace.sh` | LOW |
| `scripts/test-cleanup-backups.sh` | `scripts/test-cleanup-backups.sh` | LOW |
| `scripts/toggle-p40.example.yaml` | `scripts/toggle-p40.example.yaml` | LOW |
| `AGENTS.md` | `AGENTS.md` | LOW |
| `README.md` | `README.md` | LOW |
| `.gitignore` | `.gitignore` | LOW |

**Dependencies:** Bootstrap modules reference each other via relative paths (`lib/common.sh`, `lib/runner.sh`) — these stay within same repo, no cross-repo issues.
**Cross-references:** `AGENTS.md` references `docs/` paths — these become `vault.git/` paths.

### Batch C: INFRA → infra.git (MEDIUM risk, 37 files)

| Source | Destination | Risk |
|---|---|---|
| `scripts/llama-loader/llama-loader.sh` | `scripts/llama-loader.sh` (flatten entry) | MEDIUM |
| `scripts/llama-loader/lib/common.sh` | `lib/common.sh` | MEDIUM |
| `scripts/llama-loader/builder/*.sh` | `builder/*.sh` (4 files) | MEDIUM |
| `scripts/llama-loader/core/execution_plan.sh` | `core/execution_plan.sh` | MEDIUM |
| `scripts/llama-loader/core/run.sh` | `core/run.sh` | MEDIUM |
| `scripts/llama-loader/core/dialects/llama.cpp.sh` | `core/dialects/llama.cpp.sh` | MEDIUM |
| `scripts/llama-loader/introspect/evaluate.sh` | `introspect/evaluate.sh` | MEDIUM |
| `scripts/llama-loader/modes/*.sh` | `modes/*.sh` (4 files) | MEDIUM |
| `scripts/llama-loader/presets/*.sh` | `presets/*.sh` (4 files) | MEDIUM |
| `scripts/llama-loader/state/state.json` | `state/state.json` | MEDIUM |
| `scripts/llama-loader.old` | `llama-loader.old` (legacy) | LOW |
| `scripts/build-gold-lxc.sh` | `proxmox/build-gold-lxc.sh` | LOW |
| `scripts/lxc-bootstrap.sh` | `proxmox/lxc-bootstrap.sh` | LOW |
| `scripts/lxc-provision.sh` | `proxmox/lxc-provision.sh` | LOW |
| `scripts/lxc/core.sh` | `proxmox/lxc/core.sh` | LOW |
| `scripts/lxc/fonts.sh` | `proxmox/lxc/fonts.sh` | LOW |
| `scripts/lxc/fish.sh` | `proxmox/lxc/fish.sh` | LOW |
| `scripts/lxc/zsh.sh` | `proxmox/lxc/zsh.sh` | LOW |
| `scripts/lxc/aliases.sh` | `proxmox/lxc/aliases.sh` | LOW |
| `scripts/forge-start.sh` | `services/forge-start.sh` | LOW |
| `scripts/healthcheck.sh` | `services/healthcheck.sh` | MEDIUM |
| `scripts/llama-server.sh` | `services/llama-server.sh` | MEDIUM |
| `scripts/check-fixes.sh` | `system/check-fixes.sh` | MEDIUM |
| `scripts/live-env-setup.sh` | `system/live-env-setup.sh` | MEDIUM |
| `scripts/toggle-gpu-profile.sh` | `system/toggle-gpu-profile.sh` | LOW |
| `scripts/toggle-p40.sh` | `system/toggle-p40.sh` | LOW |

**Dependencies:**
- `llama-loader/` scripts reference each other via relative paths — restructure must preserve these internal refs
- `lxc-bootstrap.sh` sources `scripts/lxc/*.sh` — path [[changelog]]
- `llama-server.sh` and `forge-start.sh` are referenced by shell aliases in dotfiles — cross-repo ref
- `healthcheck.sh` may be referenced by cron/systemd — cross-repo ref

### Batch D: CROSS-REPO REFERENCE FIXES (HIGH risk)

Files that reference paths crossing repo boundaries:

| Source File | References | New Reference |
|---|---|---|
| `docs/vault/software/ai-tools/commands.md` | `scripts/forge-start.sh` | `infra.git/services/forge-start.sh` |
| `docs/vault/scripts/README.md` | `scripts/lxc-bootstrap.sh` etc. | `infra.git/proxmox/lxc-bootstrap.sh` |
| `AGENTS.md` | `docs/INDEX.md`, `docs/vault/...` | `vault.git/INDEX.md`, `vault.git/vault/...` |
| `docs/vault/system/system-memory.md` | `scripts/` paths | `infra.git/` or `dotfiles.git/` |
| Shell aliases in `.bashrc`/`.zshrc`/`config.fish` | `~/dotfiles/scripts/...` | `~/infra/scripts/...` or via symlink |

## Migration Order

```
Batch A (VAULT) → copy to vault.git, no downstream breakage
  ↓
Batch B (DOTFILES) → copy to dotfiles.git, update AGENTS.md refs
  ↓
Batch C (INFRA) → copy to infra.git, restructure paths
  ↓
Batch D (Cross-repo references) → update all broken links
  ↓
Validate → cleanup → final cutover
```

## Risk Summary

| Batch | Files | Risk | Reason |
|---|---|---|---|
| A (VAULT) | 178 | LOW | Self-contained markdown, no executables |
| B (DOTFILES) | 35 | LOW | Config files, bootstrap modules stay together |
| C (INFRA) | 37 | MEDIUM | Internal path [[changelog]], cross-repo script refs |
| D (FIXES) | varies | HIGH | Broken links until all batches complete |
