# dotfiles — Portable Linux user environment

This is a dotfiles repo for host **Akuma** (CachyOS/Arch, KDE Plasma 6, dual GPU).  
It is **not** a Node.js or app project — ignore any npm/playwright/prisma boilerplate.

## Bootstrap

```bash
git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Symlinks created by `bootstrap.sh`:

| Repo path | Target |
|---|---|
| `shell/.zshrc` | `~/.zshrc` |
| `shell/config.fish` | `~/.config/fish/config.fish` |
| `git/.gitconfig` | `~/.gitconfig` |
| `ssh/config` | `~/.ssh/config` |

## Shell Config

- `shell/.zshrc` sources CachyOS zsh config + defines AI aliases (`llm`, `textgen`, `llmcheck`, `llmk`, `llmstart`, `textkill`, `quickhelp`)
- `~/.zshrc` is a symlink into this repo

## Scripts

| Script | Purpose |
|---|---|
| `scripts/llama-server.sh` | llama-server wrapper — sets CUDA_PATH=/opt/cuda, execs `/mnt/workspace/llama.cpp/build/bin/llama-server` |
| `scripts/check-fixes.sh` | Quality gate for rolling updates — tracks upstream KDE bugs, blocks updates within 21d cooldown (`--gate` mode) |
| `scripts/live-env-setup.sh` | CachyOS live ISO post-install — clones dotfiles, adds drives to fstab, creates symlinks, runs bootstrap |

Key paths (not in repo, but on the system):
- `~/.local/bin/llama-loader` — interactive GGUF model selector
- `~/.openclaw/workspace/scripts/textgen-start.sh` — TextGen WebUI (port 7861)
- `~/.openclaw/workspace/scripts/llama-start.sh` — llama-server launcher
- `/workspace/textgen` — TextGen WebUI installation
- `/mnt/workspace/llama.cpp/build/bin/llama-server` — CUDA 12.9 build (sm_61 + sm_86)
- `/mnt/workspace/sd-webui-forge-neo` — SD WebUI Forge Neo

## GPU Setup

- **RTX 3060** (sm_86, 12GB) — GPU 0, port 8080 for llama.cpp
- **Tesla P40** (sm_61, 24GB) — GPU 1, port 8081, needs PCIe Gen3 kernel cmdline fix
- CUDA 12.9 at `/opt/cuda/` (system package), old CUDA 12.4 at `~/.local/cuda-12.4/` (disabled)
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"` for dual-GPU support

## Documentation (in `docs/`)

| File | Content |
|---|---|
| `INDEX.md` | **Start here — root index for the docs vault** |
| `commands.txt` | Full command reference (aliases, network, git, backups) |
| `quick-commands.txt` | Cheat sheet (AI commands, model paths, network IPs) |
| `gpu/gpu-config-notes.md` | GPU/CUDA config, dual-GPU server layout |
| `gpu/llama-setup.md` | Building llama.cpp with dual-GPU CUDA support |
| `gpu/tesla-p40-vfio-passthrough.md` | P40 VFIO passthrough configuration |
| `context/system-memory.md` | Canonical system reference — drive UUIDs, bind mounts, all config |
| `context/package-list.txt` | Package list for CachyOS reinstall |
| `context/free-models.md` | Free online model reference (OpenRouter, OpenCode Zen) |
| `context/free-providers.md` | Free LLM API provider reference |
| `reference/workspace-symlink-strategy.md` | Workspace symlink persistence across reinstalls |
| `reference/lspci-reference.md` | PCI device listing cheat sheet |
| `known-issues/temporary-hacks.md` | Active workarounds for upstream KDE bugs |
| `rebuild/rebuild-notes.md` | Latest OS rebuild notes |
| `rebuild/debian-setup-hoops.md` | Debian-specific setup gotchas |
| `vault/projects/translation-pipeline.md` | **Translation Pipeline v2.0** — multi-stage LLM pipeline (10 roles) |
| `vault/scripts/README.md` | All scripts in one place — indexed by category |
| `system_backup/REBUILD_SCRIPT.sh` | Master rebuild script for Debian |
| `system_backup/BACKUP_CHECKLIST.txt` | Backup verification checklist |

## Installation Protocol

When installing software, document every step in `docs/reference/` for reproducibility:

- Full commands with all flags (copy/paste ready)
- Annotations explaining why each step exists (gotchas, edge cases, why not the obvious approach)
- Source URLs / references for anything fetched
- Config files in full (not diffs — complete blocks)
- Service files, env vars, directory layout
- Verification commands to confirm it works

The goal: a clean OS reinstall should be fully recoverable from these docs + the dotfiles repo — no tribal knowledge required.

## Model Inventory Rule

Before editing pipeline docs or assigning models to roles, always scan actual GGUF files on disk:

```bash
find /mnt/data/model_storage/ ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'
```

Documented filenames, sizes, and quant levels regularly drift from reality. Verify before writing.

## Vault Location Conventions

| Content | Location |
|---|---|
| Pipeline role files, project-specific docs | `docs/vault/projects/` |
| Standalone reference (keyd, pipeline proposal, SearXNG setup) | `docs/vault/reference/` |
| Model spec pages (non-public) | `/mnt/workspace/ai-model-research/individual-models/` |

The model research wiki lives outside the dotfiles repo so it stays non-public.

## GPU Constraint Formula

| GPU | Max file size | Notes |
|-----|--------------|-------|
| RTX 3060 (12GB) | ~9GB | After KV cache + CUDA overhead |
| Tesla P40 (24GB) | ~20GB | PCIe Gen3, needs kernel cmdline fix |

MoE models do NOT save VRAM in llama.cpp — all expert weights are loaded per offloaded layer. File size ≈ VRAM usage for full offload. MoE only saves compute (FLOPs), not memory.