---
tags: [navigation, index]
aliases: [sitemap, map, vault-map]
updated: 2026-06-21
---

# Vault Map

```
docs/                          ← Vault root (.obsidian/ lives here)
├── INDEX.md                   ← START HERE
├── vault/
│   ├── QUICK-START.md         ← 🚨 Emergency recovery (system died, 5-min restore)
│   ├── changelog.md           ← Vault structure changes
│   ├── map.md                 ← THIS FILE — vault sitemap
│   │
│   ├── system/
│   │   ├── system-memory.md         ← ★ START HERE for rebuild
│   │   ├── drives-and-mounts.md     ← Storage layout, UUIDs, fstab, bind mounts
│   │   ├── dual-boot-recovery.md    ← Limine/MX Linux recovery, boot entry repair
│   │   ├── debian-setup-hoops.md    ← Debian 13 workarounds
│   │   ├── rebuild-notes.md         ← Build session records
│   │   ├── rebuild-script.sh        ← Full system recovery script
│   │   ├── workspace-symlink-strategy.md ← Symlink persistence plan
│   │   └── backup-checklist.md      ← Backup reference
│   │
│   ├── hardware/
│   │   └── gpu/
│   │       ├── config-notes.md      ← GPU driver + CUDA + llama.cpp
│   │       └── tesla-p40-vfio.md    ← P40 VFIO passthrough
│   │
│   ├── software/
│   │   ├── ai-tools/
│   │   │   ├── commands.md          ← AI command reference (llm, sdxl, textgen, oc)
│   │   │   ├── llama-setup.md       ← llama.cpp — build, GPU layout, P40
│   │   │   ├── forge-neo.md         ← Forge Neo — Debian + CachyOS
│   │   │   ├── textgen-webui.md     ← TextGen WebUI — Debian + CachyOS
│   │   │   ├── ollama-notes.md      ← Ollama GPU/CPU switching
│   │   │   ├── free-models.md       ← Free model reference
│   │   │   └── free-providers.md    ← Free API providers
│   │   ├── conky/
│   │   │   ├── system-cockpit.md    ← Unified Conky telemetry HUD
│   │   │   └── heat-aware-cockpit.md ← Thermal-reactive Conky cockpit
│   │   ├── kde/
│   │   │   ├── settings-backup.md   ← KDE Plasma settings backup/restore
│   │   │   ├── workarounds.md       ← Tracked KDE bugs
│   │   │   ├── temporary-hacks.md   ← Active KDE workarounds
│   │   │   └── dolphin-config.md    ← Dolphin file manager config
│   │   ├── opencode/
│   │   │   ├── plugins.md           ← OpenCode plugin recommendations
│   │   │   └── serena-mcp.md        ← Serena MCP toolkit
│   │   ├── prompt-hats/
│   │   │   ├── INDEX.md             ← 22 stable hats + E1–E8 experimental
│   │   │   └── ... (30 hat files)
│   │   ├── quartz/
│   │   │   ├── setup.md             ← Quartz v5 installation
│   │   │   └── container-plan.md    ← LXC container deployment
│   │   ├── searxng/
│   │   │   └── setup.md             ← SearXNG metasearch setup
│   │   ├── packages/
│   │   │   ├── cachyos-package-list.md
│   │   │   └── debian-package-list.md
│   │   ├── gaming/
│   │   │   └── gw2-multibox-wine-setup.md
│   │   ├── dev-setup.md             ← Python venv, git, shell, bootstrap
│   │   └── kvm-bridge-networking.md ← KVM/libvirt bridge (LAN DHCP for VMs)
│   │
│   ├── reference/
│   │   ├── architecture-snapshot.md      ← 🧭 Full homelab architecture
│   │   ├── ai-ssh-architecture.md        ← 🧩 Restricted ai-user SSH
│   │   ├── lxc-build-log.md              ← 🧱 LXC 300 build + gold pipeline
│   │   ├── proxmox-ssh-infrastructure.md ← SSH key injection, agent access
│   │   ├── quartz-constitution.md        ← AI project constitution
│   │   ├── chat-ingestion-architecture.md ← Vault memory architecture
│   │   ├── index-retrieval-system.md     ← Index format + retrieval pipeline
│   │   ├── vault-query-scripts.md        ← Vault query scripts
│   │   ├── memory-reasoning-execution-pipeline.md
│   │   ├── libvirt-bridge-setup.md       ← Zero-touch KVM bridge
│   │   ├── keyd-stack.md                ← keyd upstream install + remap
│   │   ├── key-locations.md             ← Key file locations
│   │   ├── commands.md                  ← Full command reference
│   │   ├── quick-commands.md            ← Condensed cheat sheet
│   │   ├── faq.md                       ← Common questions
│   │   ├── glossary.md                  ← Term definitions
│   │   ├── bugs-and-workarounds.md      ← Active upstream bugs
│   │   ├── boot-diagnostics.md          ← Boot timing debug
│   │   ├── lspci-reference.md           ← lspci cheat sheet
│   │   ├── lspci-akuma-output.md        ← Live PCI topology
│   │   ├── fixbot-chatlog.md            ← FixBot chat log
│   │   ├── knowledge-audit.md           ← Documentation knowledge audit
│   │   ├── ssh-key-setup.md             ← SSH key reference
│   │   └── agent-hallucination-techniques.md
│   │
│   ├── scripts/
│   │   └── README.md           ← Script index — reinstall order + GPU/AI + system
│   │
│   ├── projects/
│   │   ├── README.md           ← Project index
│   │   ├── translation-pipeline.md
│   │   └── sd-webui-forge-neo.md
│   │
│   ├── context/
│   │   └── INDEX.md            ← Context docs index
│   │
│   ├── research/
│   │   ├── runbook-architecture.md        ← Runbook structure proposal
│   │   └── vault-organization-principles.md ← Vault org rules
│   │
│   └── archive/
│       ├── scratchpad.md
│       ├── storage-layout-plan.md
│       ├── implementation-workflow.md
│       ├── system-profile-cachyos.md
│       └── ... (historical backups)
```

## Navigation Paths

| Scenario | Where to Go |
|----------|-------------|
| I just reinstalled the OS | [[QUICK-START]] |
| I need to find something | [[INDEX]] |
| My GPU isn't working | [[hardware/gpu/config-notes]] |
| I need a command | [[software/ai-tools/commands]] or [[reference/commands]] |
| What does this term mean? | [[reference/glossary]] |
| Common questions | [[reference/faq]] |
| What's broken right now? | [[reference/bugs-and-workarounds]] |
| Drive full, where do I put things? | [[system/drives-and-mounts]] |
