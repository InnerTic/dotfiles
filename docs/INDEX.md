# Docs Vault

System documentation, rebuild references, GPU config, cheat sheets, and AI context.
Start here to navigate the vault.

## Quick Navigation

| Page | Description |
|------|-------------|
| [[context/system-memory]] | **START HERE for rebuild.** Drives, mounts, UUIDs, aliases, network, GW2. Updated 2026-05-10. |
| [[context/INDEX]] | Full context docs index — system profile, packages, KDE settings, model lists, providers |
| [[gpu-config-notes]] | GPU stack — driver 580.159.04, CUDA 12.9, dual-GPU (RTX 3060 + Tesla P40) |
| [[llama-setup]] | Building llama.cpp with dual-GPU CUDA support (sm_61 + sm_86) |
| [[workspace-symlink-strategy]] | Workspace symlink setup — persist .ssh, .librewolf, dotfiles, openclaw, opencode across reinstalls |
| [[lspci-reference]] | lspci cheat sheet — flags, combos, filtering, PCI topology |
| [[lspci-akuma-output]] | Live lspci output for this system — slot map, drivers, bus topology |

## Rebuild & Recovery

| Page | Description |
|------|-------------|
| [[rebuild-notes]] | Latest rebuild notes — step-by-step OS reinstall |
| [[context/implementation-workflow]] | Original migration workflow (historical, some paths stale) |
| `system_backup/` | Full backup/restore reference — REBUILD_SCRIPT.sh, KEY_LOCATIONS.txt |
| [[tesla-p40-vfio-passthrough]] | VFIO passthrough config for Tesla P40 |

## Cheat Sheets

| Page | Description |
|------|-------------|
| `commands.txt` | Full command reference — aliases, network, git, backups |
| `quick-commands.txt` | Condensed cheat sheet — AI commands, model paths, network IPs |
| [[lspci-reference]] | PCI device listing — all flags, examples, this system's devices |

## GPU Configuration

| Page | Description |
|------|-------------|
| [[gpu-config-notes]] | Working combo: 580.159.04 + CUDA 12.9 + llama.cpp |
| [[llama-setup]] | Building with CMAKE_CUDA_ARCHITECTURES="61;86" |
| [[tesla-p40-vfio-passthrough]] | P40 passthrough details |
| [[context/kde-workarounds]] | KDE bugs affecting GPU setup (temporary hacks) |

## Known Issues

| Page | Description |
|------|-------------|
| [[temporary-hacks]] | Active workarounds for upstream KDE bugs |
| [[context/kde-workarounds]] | Tracked KDE bugs with review-by dates |

## Context Vault

The [[context/INDEX|context/ directory]] contains the detailed AI reference docs — organized by CURRENT and HISTORICAL:

- **Current:** system-memory, quick-commands, free-models, free-providers, package-list, KDE settings, KDE workarounds
- **Historical:** storage-layout-plan, implementation-workflow, system-profile, ollama-notes, opencode-plugins, serena-mcp

## Vault Docs (Structured)

| Page | Description |
|------|-------------|
| [[vault/QUICK-START]] | 🚨 Emergency recovery — 5-minute restore after reinstall |
| [[vault/map]] | Full vault sitemap — navigation paths for every scenario |
| [[vault/system/drives-and-mounts]] | Drive UUIDs, fstab, bind mounts, drive selection guide |
| [[vault/software/dev-setup]] | Python venv, git config, shell aliases, bootstrap process |
| [[vault/software/ai-tools/commands]] | AI command reference — llm, sdxl, textgen, oc |
| [[vault/reference/faq]] | Common questions — models, GPUs, system, gaming, network |
| [[vault/reference/glossary]] | Term definitions — llama.cpp, VFIO, CUDA, GGUF, etc. |
| [[vault/reference/bugs-and-workarounds]] | Active upstream bugs and their workarounds |
| [[vault/changelog]] | Vault structure changes |

## External References

| Location | Content |
|----------|---------|
| `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` | Full FixBot chat log (5269 lines, 300KB) — GW2 debugging |
| `/mnt/workspace/memory/` | OpenCode memory wiki — session state, learned patterns |
| [[gw2-multibox-wine-setup]] | GW2 multi-boxing setup on Wine |
