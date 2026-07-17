---
tags: [research, vault-architecture, organization]
status: proposed
source: opencode-session-2026-06-21
---

# Vault Organization Principles — Research Note

## The Problem

Organizing by OS first creates parallel universes:

```
debian/
├── quartz.md
├── homepage.md
├── fish.md

cachyos/
├── quartz.md
├── homepage.md
├── fish.md
```

Knowledge duplicated. You have to remember which distro tree to search in.

## The Solution

Organize by **thing** (the software/project/component), then use distro subsections inside.

### By Subject

```
Quartz
Homepage
OpenWebUI
SSH
Proxmox
Fish
```

### Distro Subsections When Needed

```
Quartz
├── Overview
├── Debian
│   ├── Prerequisites (apt install ...)
│   ├── Notes
│   └── Failure Modes
└── Arch/CachyOS
    ├── Prerequisites (pacman -S ...)
    └── Notes
```

### Distro Folders Only When the Distro Is the Subject

```
system/debian/
├── apt-cheatsheet.md
├── debian-setup-hoops.md
└── lxc-baseline.md

system/cachyos/
├── pacman-cheatsheet.md
├── fish-defaults.md
└── rebuild-notes.md
```

## Why

When Future Ken thinks "how did I install Quartz?", he searches `Quartz` — not `Debian`. The OS is a detail of the implementation, not the primary axis of organization.

## Implied Restructuring

- `docs/reinstall-guides/debian/forge-neo.md` → `vault/software/forge-neo.md` (with `## Debian` section)
- `docs/reinstall-guides/cachyos/forge-neo.md` → same file, `## CachyOS` section
- `docs/rebuild/debian-setup-hoops.md` → `vault/system/debian/setup-hoops.md` (distro IS the subject)
- `docs/rebuild/rebuild-notes.md` → `vault/reference/rebuild-notes.md` (or `vault/system/cachyos/`)
- `docs/quartz-container-plan.md` → `vault/software/quartz.md` (or `vault/containers/quartz-base.md`)

## References

- Proposed during 2026-06-21 opencode session
- Related: [[research/runbook-architecture]] — operations cookbook structure
