# Docs Vault

System documentation, rebuild references, GPU config, cheat sheets, and AI context.

> **On `deb` branch.** Switch to `main` for Arch/CachyOS docs: `git checkout main`

## Quick Navigation

| Page | Description |
|------|-------------|
| [[vault/system/system-memory\|system-memory]] | **START HERE for rebuild.** Drives, mounts, UUIDs, aliases, network |
| [[vault/map]] | Full vault sitemap — navigation paths for every scenario |
| [[vault/QUICK-START]] | 🚨 Emergency recovery — 5-minute restore after reinstall |
| [[vault/hardware/gpu/config-notes\|gpu/config-notes]] | GPU stack — driver, CUDA, dual-GPU (RTX 3060 + Tesla P40) |
| [[vault/software/ai-tools/llama-setup\|ai-tools/llama-setup]] | Building llama.cpp with dual-GPU CUDA support (sm_61 + sm_86) |
| [[vault/software/ai-tools/commands\|commands]] | AI command reference — llm, sdxl, textgen, oc |
| [[vault/reference/quick-commands\|quick-commands]] | Condensed cheat sheet — AI commands, model paths, network IPs |
| [[vault/software/prompt-hats/INDEX\|prompt-hats]] | 22 stable hats + 8 experimental |

## Rebuild & Recovery

| Page | Description |
|------|-------------|
| [[vault/scripts/README\|vault/scripts]] | All scripts — reinstall sequence, GPU/AI tools, system helpers |
| [[vault/system/rebuild-notes\|rebuild-notes]] | Latest rebuild session notes |
| [[vault/system/debian-setup-hoops\|debian-setup-hoops]] | Debian 13 workarounds (when on `deb` branch) |
| [[vault/system/rebuild-script.sh\|REBUILD_SCRIPT.sh]] | Full system recovery script |

## Software

| Page | Description |
|------|-------------|
| [[vault/software/ai-tools/forge-neo\|forge-neo]] | SD WebUI Forge Neo install (Debian + CachyOS) |
| [[vault/software/ai-tools/llama-setup\|llama-setup]] | llama.cpp install — build, GPU layout, P40 considerations |
| [[vault/software/ai-tools/textgen-webui\|textgen-webui]] | TextGen WebUI (oobabooga) install |
| [[vault/software/quartz/container-plan\|quartz/container-plan]] | LXC container deploy plan |
| [[vault/software/quartz/setup\|quartz/setup]] | Quartz v5 digital garden setup |

## System & Hardware

| Page | Description |
|------|-------------|
| [[vault/system/drives-and-mounts\|drives-and-mounts]] | Drive UUIDs, fstab, bind mounts |
| [[vault/system/dual-boot-recovery\|dual-boot-recovery]] | Limine/MX Linux recovery, boot entry repair |
| [[vault/system/workspace-symlink-strategy\|workspace-symlink-strategy]] | Symlink setup for reinstall persistence |
| [[vault/hardware/gpu/config-notes\|gpu/config-notes]] | GPU driver + CUDA config |
| [[vault/hardware/gpu/tesla-p40-vfio\|tesla-p40-vfio]] | P40 VFIO passthrough |

## Conky Telemetry

| Page | Description |
|------|-------------|
| [[vault/software/conky/system-cockpit\|conky/system-cockpit]] | Unified Conky HUD — CPU/GPU/RAM/NET |
| [[vault/software/conky/heat-aware-cockpit\|conky/heat-aware-cockpit]] | Thermal-reactive cockpit design |

## Vault Reference

| Page | Description |
|------|-------------|
| [[vault/reference/architecture-snapshot\|architecture-snapshot]] | 🧭 Homelab architecture — network, Proxmox, LXC, auth |
| [[vault/reference/ai-ssh-architecture\|ai-ssh-architecture]] | 🧩 Restricted ai-user SSH pattern |
| [[vault/reference/lxc-build-log\|lxc-build-log]] | 🧱 LXC 300 build log + gold pipeline |
| [[vault/reference/proxmox-ssh-infrastructure\|proxmox-ssh-infrastructure]] | SSH key injection, LXC bootstrap, agent access |
| [[vault/reference/faq\|faq]] | Common questions |
| [[vault/reference/glossary\|glossary]] | Term definitions |
| [[vault/reference/bugs-and-workarounds\|bugs-and-workarounds]] | Active upstream bugs and workarounds |
| [[vault/reference/commands\|commands]] | Full command reference |
| [[vault/reference/key-locations\|key-locations]] | Key file locations |
| [[vault/reference/knowledge-audit\|knowledge-audit]] | Documentation knowledge audit |

## External References

| Location | Content |
|----------|---------|
| `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` | Full FixBot chat log — GW2 debugging |
| `/mnt/workspace/memory/` | OpenCode memory wiki — session state, learned patterns |
