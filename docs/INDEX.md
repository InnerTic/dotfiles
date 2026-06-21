n# Docs Vault — Debian

System documentation, rebuild references, GPU config, cheat sheets, and AI context.
Start here to navigate the vault.

> **On the `deb` branch.** Switch to `main` for Arch/CachyOS docs.
> `cd ~/dotfiles && git checkout main`

## Quick Navigation

| Page | Description |
|------|-------------|
| [[context/system-memory]] | **START HERE for rebuild.** Drives, mounts, UUIDs, aliases, network, GW2. Updated 2026-05-10. |
| [[context/INDEX]] | Full context docs index — system profile, packages, KDE settings, model lists, providers |
| [[gpu/gpu-config-notes]] | GPU stack — driver 580.159.04, CUDA 12.9, dual-GPU (RTX 3060 + Tesla P40) |
| [[gpu/llama-setup]] | Building llama.cpp with dual-GPU CUDA support (sm_61 + sm_86) |
| [[reference/workspace-symlink-strategy]] | Workspace symlink setup — persist .ssh, .librewolf, dotfiles, openclaw, opencode across reinstalls |
| [[reference/lspci-reference]] | lspci cheat sheet — flags, combos, filtering, PCI topology |
| [[reference/lspci-akuma-output]] | Live lspci output for this system — slot map, drivers, bus topology |

## Rebuild & Recovery

| Page | Description |
|------|-------------|
| `reinstall-guides/` | **Step-by-step install guides** for llama.cpp, forge-neo, textgen — separated by distro (cachyos/ debian) with CUDA version, python version, and gotcha notes |
| [[vault/scripts/README\|vault/scripts/]] | **All scripts in one place** — reinstall sequence, GPU/AI tools, system helpers |
| [[rebuild/rebuild-notes]] | Latest rebuild notes — step-by-step OS reinstall |
| [[context/implementation-workflow]] | Original migration workflow (historical, some paths stale) |
| `system_backup/` | Full backup/restore reference — REBUILD_SCRIPT.sh, KEY_LOCATIONS.txt |
| [[gpu/tesla-p40-vfio-passthrough]] | VFIO passthrough config for Tesla P40 |

## Cheat Sheets

| Page | Description |
|------|-------------|
| `reference/commands.txt` | Full command reference — aliases, network, git, backups |
| `reference/quick-commands.txt` | Condensed cheat sheet — AI commands, model paths, network IPs |
| [[reference/lspci-reference]] | PCI device listing — all flags, examples, this system's devices |

## Prompt Hats

| Page | Description |
|------|-------------|
| [[vault/software/prompt-hats/INDEX\|prompt-hats/]] | 22 stable hats + 8 experimental — role-switching prompt stack for llama.cpp webchat |

## Conky Telemetry

| Page | Description |
|------|-------------|
| [[conky-system-cockpit]] | Unified Conky HUD — CPU/GPU/RAM/NET visual grammar |
| [[heat-aware-cockpit]] | Thermal-reactive cockpit design — green/yellow/red bands |
| [[heat-aware-dropin]] | Merged heat-aware drop-in config reference |

## VM / Networking

| Page | Description |
|------|-------------|
| [[vault/reference/libvirt-bridge-setup\|libvirt-bridge-setup]] | Zero-touch br0 bridge for KVM VMs (CachyOS/Arch) |

## GPU Configuration

| Page | Description |
|------|-------------|
| [[gpu/gpu-config-notes]] | Working combo: 580.159.04 + CUDA 12.9 + llama.cpp |
| [[gpu/llama-setup]] | Building with CMAKE_CUDA_ARCHITECTURES="61;86" |
| [[gpu/tesla-p40-vfio-passthrough]] | P40 passthrough details |
| [[context/kde-workarounds]] | KDE bugs affecting GPU setup (temporary hacks) |

## Known Issues

| Page | Description |
|------|-------------|
| [[known-issues/temporary-hacks]] | Active workarounds for upstream KDE bugs |
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
| [[vault/system/dual-boot-recovery]] | Limine/MX Linux recovery — boot entry repair, UEFI fallbacks |
| [[vault/software/dev-setup]] | Python venv, git config, shell aliases, bootstrap process, fastfetch greeting |
| [[vault/software/kvm-bridge-networking]] | KVM/libvirt bridge setup — LAN DHCP for VMs, no NAT |
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
| [[gaming/gw2-multibox-wine-setup]] | GW2 multi-boxing setup on Wine |
| [[vault/reference/proxmox-ssh-infrastructure]] | Proxmox SSH infrastructure — key injection, LXC bootstrap, AI agent access |
| [[vault/reference/architecture-snapshot]] | 🧭 Homelab architecture snapshot — network, Proxmox, LXC, auth, ops rules |
| [[vault/reference/lxc-build-log]] | 🧱 LXC 300 build log — full quartz-test build sequence, step-by-step |
| [[vault/reference/ai-ssh-architecture]] | 🧩 AI SSH architecture — restricted ai-user, command wrapper, no root |
