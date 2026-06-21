---
tags: [navigation, index]
aliases: [sitemap, map, vault-map]
updated: 2026-06-17
---

# Vault Map

```
docs/                          ← Vault root (.obsidian/ lives here)
├── INDEX.md                   ← START HERE — root index
├── conky-system-cockpit.md    ← Unified Conky telemetry HUD (CPU/GPU/RAM/NET)
├── heat-aware-cockpit.md      ← Thermal-reactive Conky cockpit design
├── heat-aware-dropin.md       ← Merged heat-aware Conky config reference
├── vault/
│   ├── QUICK-START.md         ← 🚨 Emergency recovery (system died, 5-min restore)
│   ├── system/
│   │   ├── drives-and-mounts.md ← Storage layout, UUIDs, fstab, bind mounts
│   │   └── dual-boot-recovery.md ← Limine/MX Linux recovery, boot entry repair
│   ├── software/
│   │   ├── ai-tools/
│   │   │   └── commands.md    ← AI command reference (llm, sdxl, textgen, oc)
│   │   ├── dev-setup.md       ← Python venv, git, shell, bootstrap
│   │   ├── kvm-bridge-networking.md ← KVM/libvirt bridge setup (LAN DHCP for VMs)
│   │   └── prompt-hats/
│   │       └── INDEX.md       ← 22 stable hats + E1–E8 experimental
│   ├── reference/
│   │   ├── glossary.md         ← Term definitions (llama.cpp, VFIO, CUDA, etc.)
│   │   ├── faq.md              ← Common questions
│   │   ├── bugs-and-workarounds.md ← Active workarounds for upstream bugs
│   │   ├── libvirt-bridge-setup.md ← Zero-touch br0 bridge for KVM VMs
│   │   ├── architecture-snapshot.md ← 🧭 Full architecture — network, Proxmox, LXC, auth, ops
│   │   ├── lxc-build-log.md         ← 🧱 LXC 300 quartz-test — full build sequence + gold image pipeline
│   │   ├── proxmox-ssh-infrastructure.md ← SSH key injection, LXC bootstrap, agent access
│   │   └── ai-ssh-architecture.md       ← 🧩 Restricted ai-user, command wrapper, no root
│   ├── scripts/
│   │   └── README.md           ← Script index — reinstall order + GPU/AI + system scripts
│   └── changelog.md            ← Vault structure changes
│
├── context/                    ← Detailed AI reference docs
│   ├── INDEX.md                ← Context index (CURRENT / HISTORICAL sections)
│   ├── system-memory.md        ← ★ START HERE for rebuild
│   ├── quick-commands.md       ← AI tool quick-start commands
│   ├── free-models.md          ← Free model reference
│   ├── free-providers.md       ← Free API providers
│   ├── package-list.txt        ← CachyOS package list
│   ├── kde-settings.md         ← KDE backup/restore
│   ├── kde-workarounds.md      ← Tracked KDE bugs
│   └── ... (historical: storage-layout, system-profile, etc.)
│
├── gpu/
│   ├── gpu-config-notes.md     ← Working combo (driver + CUDA + llama.cpp)
│   ├── llama-setup.md          ← Building llama.cpp with dual-GPU CUDA
│   └── tesla-p40-vfio-passthrough.md ← P40 VFIO config
│
├── reference/
│   ├── lspci-reference.md      ← lspci cheat sheet
│   ├── lspci-akuma-output.md   ← Live PCI topology for this system
│   ├── workspace-symlink-strategy.md ← Symlink persistence plan
│   ├── commands.txt            ← Full command reference
│   └── quick-commands.txt      ← Condensed cheat sheet
│
├── gaming/
│   └── gw2-multibox-wine-setup.md ← GW2 multi-box setup
│
├── known-issues/
│   └── temporary-hacks.md      ← Active KDE workarounds
│
├── rebuild/
│   ├── rebuild-notes.md        ← Latest OS rebuild steps
│   └── debian-setup-hoops.md   ← Debian-specific gotchas
│
├── system_backup/              ← Full backup/restore reference
│   └── REBUILD_SCRIPT.sh       ← 8-step rebuild script
│
└── .obsidian/                  ← Obsidian vault config (hotkeys, etc.)
```

## Navigation Paths

### I just reinstalled the OS → [[QUICK-START]]
### I need to find something → [[INDEX]]
### My GPU isn't working → [[gpu/gpu-config-notes]]
### I need a command → [[software/ai-tools/commands]] or `reference/commands.txt`
### What does this term mean? → [[reference/glossary]]
### Common questions → [[reference/faq]]
### What's broken right now? → [[reference/bugs-and-workarounds]]
### Drive full, where do I put things? → [[system/drives-and-mounts]]
