---
tags: [meta, changelog]
aliases: [vault-changelog, changes]
updated: 2026-06-24
---

# Vault Changelog

## 2026-07-18 — CachyOS restore point: fstab, LibreWolf, G502, cache cleanup

- **LibreWolf**: profile version mismatch fix (152→151), `librewolf.overrides.cfg` created with vault-standard privacy settings, `policies.json` with SearXNG (172.16.12.16:8888), pacman hook for persistence across updates
- **Fstab**: fixed UUIDs for sdc1 HDD-Data (was ntfs→btrfs) and sde4 vm-storage, added `nofail` to /boot and /home, removed USB/EFI partitions from fstab
- **Cache cleanup**: removed `~/.cache/Shelly/` (20G), paru source clones, pip cache (2.7G), go build cache (1.3G), orphaned packages
- **Packages installed**: `go`, `zip`, `tmux`, `python-virtualenv`, `python-pip`, `meson`, `ninja`, `check`, `swig`
- **G502 Hero**: `libratbag` + `piper` installed, button mappings reconfigured (back→X11 btn4, C, V, 2/N on scroll), libratbag built from git with PR #1843 fix for stale modifier bug
- **keyd**: documented known issue — keyd breaks keyboard input in Wine/Steam/GW2 ([[reference/keyd-stack]])
- **CoolerControl**: vault doc added ([[software/coolercontrol]])
- **Vault audit**: compared CachyOS against vault docs, noted drift (script paths, git user, drive letters)
- [[software/g502-hero-setup]] [[software/librewolf]] [[software/coolercontrol]] [[reference/keyd-stack]]

## 2026-06-24 — AI Watchtower project, vault research, script consolidation

- AI Watchtower project: gold-template constraint, bootstrap scripts (LXC + stack)
- Research files: [[research/ai-bubble-reality-check]], [[research/ai-coding-drill-ladder]]
- Drift annotations: commands.md, [[system-memory]].md fully annotated
- `migrate-home-data.sh` archived (one-time seed, reference only)
- Script consolidation flagged: AI scripts → `~/.local/bin/`
- Hyalo auto-link applied (34 wiki-links)

## 2026-06-23 — Quartz LXC, vault restore, wiki index

- Quartz LXC deployment: two-stage bootstrap (host + container), nginx, /status endpoint
- Vault content restored: 149 files recovered from git history, synced to LXC
- `content/index.md` created as proper root landing page
- Graph view disabled, explorer sidebar cleaned up
- Modular bootstrap system, container-aware shell module
- GnuPG backup, version requirements policy
- Merge main → deb (13 conflicts resolved)
- Flat `docs/reference/` docs added alongside restored vault

## 2026-06-21 — Conky, heat-aware libvirt, merge main→deb

- Added conky docs ([[system-cockpit]], [[heat-aware-cockpit]])
- Added [[kvm-bridge-networking]] (Arch corrections)
- Merged llama-loader integrity + storage topology docs

## 2026-06-19 — LLM pipeline, vault-query, Quartz, scripts

- Chat ingestion architecture, memory→reasoning→execution pipeline
- Index-retrieval system, vault-query scripts (fish + bash)
- Quartz constitution + v5 setup docs
- Modular llama-loader, [[meta-scripts]] orchestrator
- [[libvirt-bridge-setup]]-setup, translation pipeline with 10 role docs

## 2026-06-15 — Debian branch, vault expansion

- Created deb branch with Debian 13 support
- Vault expansion: [[dev-setup]], [[faq]], [[bugs-and-workarounds]], [[drives-and-mounts]], [[map]], frontmatter
- Init Obsidian vault at docs/ root

## 2026-06-12 — CUDA 12.9, P40 VFIO

- CUDA 12.9 upgrade docs, P40 passthrough guide

## 2026-06-05 — CUDA dual-arch, P40 fixes

- CUDA 12.4 sm_61+sm_86 build, P40 kernel cmdline fix

## 2026-05-10 — System memory, storage layout

- [[system-memory]], [[drives-and-mounts]], GW2 setup, rebuild notes
- Marked stale docs historical vs current

## 2026-05-09 — Commands, quick-commands

- Command reference docs, q search function
