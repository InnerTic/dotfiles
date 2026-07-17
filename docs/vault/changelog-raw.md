---
tags: [meta, changelog, raw]
aliases: [raw-changelog, full-changelog, changelog-raw]
updated: 2026-06-24
---

# Vault Changelog (Raw)

Complete chronological history for AI reference. Each entry covers a session's work.

## 2026-06-24 — AI Watchtower, vault research, script archive

- **AI Watchtower project**: [[projects/ai-watchtower]] updated with gold-template deployment constraint and explicit Quartz/[[projects/ai-watchtower|Watchtower]] role split table
- **Watchtower bootstrap scripts**: `scripts/bootstrap-watchtower-lxc.sh` (Proxmox host level) + `scripts/bootstrap-watchtower-stack.sh` (container stack: Python venv, SQLite schema, directory layout, systemd timer placeholders)
- **Research**: [[research/ai-bubble-reality-check]] — market scenarios, tripwires, evidence log
- **Research**: [[research/ai-coding-drill-ladder]] — 15-level progressive AI coding skill evaluation framework
- **Archive**: [[scripts/archive/migrate-home-data]].sh + .md moved from active `scripts/` to `scripts/archive/` — one-time seed-data script, kept for historical reference
- **Drift annotations completed**: commands.md model list/script paths marked STALE; [[system-memory]].md AI Tool Aliases section annotated; script consolidation needed flagged
- **Hyalo auto-link**: 34 wiki-links applied across changelog-raw.md, [[VAULT-TODO]].md, index.md, projects/[[ai-bubble-watchboard]].md, projects/[[ai-watchtower]].md, projects/[[ai-watchtower]].md, projects/[[local-ai-control-tower]].md, scripts/README.md
- **Vault synced + Quartz rebuilt** (826 files emitted)

## 2026-06-23 (late) — Vault drift audit

- **Drift assessment added** to 4 high-drift files: [[system-memory]].md, [[drives-and-mounts]].md, gpu/[[config-notes]].md, commands.md
- Each section annotated: STATIC (no drift expected), CURRENT (verified valid), DUAL-BOOT (applies per-OS), or needs-verify
- Annotations account for dual-boot (Debian 13 + CachyOS) — drive letters differ per OS
- Key findings:
  - [[system-memory]].md: Debian-leaning; drive letters, UUIDs, script paths differ on CachyOS
  - gpu/[[config-notes]].md: CachyOS; P40 may be VFIO-bound depending on boot
  - commands.md: model list, script paths stale
  - [[drives-and-mounts]].md: same drive-letter drift as [[system-memory]]
  - Script consolidation needed: AI scripts scattered across `~/.openclaw/workspace/scripts/`, `~/workspace/`, `~/dotfiles/scripts/` — should consolidate to `~/.local/bin/`
- **[[migrate-home-data]].sh archived**: one-time seed-data script (originals stayed, was a copy not a migration). Moved to `scripts/archive/` for historical reference. Active `scripts/` now filtered. If future one-time scripts are added, archive after confirming run.

## 2026-06-23 — Quartz LXC, vault restore, wiki index

- **Quartz LXC deployment**: Two-stage bootstrap (host LXC creation + container stack), nginx on port 80 with [[software/quartz/setup|status endpoint]]
- **Vault content restored**: 149 vault files recovered from git history, synced alongside flat [[reference/software-version-requirements|reference docs]] to LXC content
- **Wiki links auto-linked**: [[software/quartz/setup]] + [[software/quartz/container-plan]] added via hyalo
- **Flat content deployed**: `docs/` only via rsync, Quartz v5 flat `.html` output
- **Root index redirect**: replaced meta-refresh with proper [[index]]
- **NP default crash fix**: [[software/ai-tools/llama-setup|llama-loader]] concurrency.sh line 16
- **Modular bootstrap system**: [[scripts/README|scripts/bootstrap/]]
- **Container-aware shell module**: LXC/Docker/Podman detection
- **GnuPG backup**: encrypted private key export
- **Version requirements policy**: [[reference/software-version-requirements]]
- **Status endpoint + update script**: `generate-status.sh`, `update-quartz.sh`, `nginx-status.conf`
- **Merge main → deb**: 13 conflicts resolved
- **nginx config**: `try_files $uri $uri.html $uri/ =404` for Quartz flat output
- **Graph View disabled**: blank component removed from sidebar
- **[[index]] created**: [[index]] at content root
- **Tools installed**: kb-lint, vlt, hyalo-cli, rustup
- **Flat [[reference/software-version-requirements|reference docs]] added alongside restored vault**

## 2026-06-21 — Conky, heat-aware libvirt, vault map, merge

- Added [[conky/system-cockpit]], [[conky/heat-aware-cockpit]]
- Added [[software/kvm-bridge-networking]]
- Updated [[index]], [[map]], [[scripts/README]]
- Added [[reference/libvirt-bridge-setup]]
- Added [[projects/meta-scripts]], [[projects/README]]
- Merge main → deb — llama-loader integrity + storage topology docs unification

## 2026-06-20 — Proxmox SSH, prompt-hats sync

- Added [[reference/proxmox-ssh-infrastructure]] — SSH key injection, LXC bootstrap, restricted access
- Synced [[software/prompt-hats/INDEX|prompt-hats]], modular llama-loader, [[conky/system-cockpit|conky]] + [[conky/heat-aware-cockpit|heat-aware]] docs

## 2026-06-19 — LLM pipeline, vault-query, Quartz constitution, scripts

- **Chat ingestion architecture**: [[reference/chat-ingestion-architecture]] — episode/knowledge/decision/artifact model
- **Memory→reasoning→execution pipeline**: [[reference/memory-reasoning-execution-pipeline]]
- **Index-retrieval system**: [[reference/index-retrieval-system]] — scoring tiers, agent prompt, full memory loop
- **Quartz constitution + v5 setup**: [[reference/quartz-constitution]], [[software/quartz/setup]]
- **Vault-query scripts**: [[reference/vault-query-scripts]] — fish frontend + bash backend + ranking logic
- **llama-loader**: integrity contract, strict type separation, modular directory architecture
- **Translation pipeline**: per-role docs (10 roles), full model index with evaluations
- **[[meta-scripts]]**: modular script orchestrator blueprint
- **[[libvirt-bridge-setup]]-setup**: bash + fish zero-touch br0/kvm bridge bootstrap
- **Fixed sde partition layout** across all docs + [[REBUILD_SCRIPT]] [[drives-and-mounts]]
- **Purged CUDA 12.4/gcc9** from Arch context, split [[software/ai-tools/llama-setup]]

## 2026-06-18 — Dual-boot recovery, CUDA purge, rebuild notes

- Added [[system/dual-boot-recovery]] — Limine/MX Linux [[QUICK-START]], boot entry repair
- Added keyboard input reference
- Purged CUDA 12.4/gcc9 from Arch context
- [[system/rebuild-notes]]: OpenCode/OpenClaw, Hermes, Forge fixes

## 2026-06-17 — SearXNG, translation pipeline, fastfetch, vault restructure

- **SearXNG**: installed and documented [[software/searxng/setup]] + MCP server
- **Translation pipeline**: [[projects/translation-pipeline]] with per-role docs (parser, [[glossary]], briefer, translator, editor, script-checks, style-auditor, consistency-checker, verifier, continuity-updater)
- **[[fastfetch]]**: per-GPU VRAM display, tide version, sectioned layout, color code fixes
- **OpenCode MCP**: [[software/opencode/plugins]], [[software/opencode/serena-mcp]]
- **Vault restructure**: reorg flat docs into sections, add [[research/vault-organization-principles|research wiki]]
- **Script checks**: upgrade to deterministic validation gate
- **Projects section**: [[projects/translation-pipeline]], [[projects/sd-webui-forge-neo]], prompt enhancer
- **Reference docs**: [[reference/translation-pipeline-proposal]], [[reference/translation-pipeline-spec]]

## 2026-06-16 — Debian 13 setup hoops

- Created [[system/debian-setup-hoops]] — full installation workaround log
- Added gradio/huggingface-hub version pin workarounds

## 2026-06-15 — Debian branch, vault expansion

- Created `deb` branch with Debian 13 support
- Added branch switching notes to [[software/dev-setup]]
- Added Debian markers to [[index]] and [[system/system-memory]]
- **Vault expansion**: [[software/dev-setup]], [[reference/faq]], [[reference/bugs-and-workarounds]], [[system/drives-and-mounts]]
- Created [[index]] as root [[index]] with wikilinks
- Created [[map]] — vault navigation/[[map]]
- Added YAML frontmatter (tags, aliases, updated) to all vault files
- Fixed broken wikilinks in [[QUICK-START]]

## 2026-06-14 — Obsidian vault init, disk split, quick-start

- Init Obsidian vault at docs/ root with [[index]] + wikilinks
- [[system/workspace-symlink-strategy]] — plan, reasons, what/why/how
- [[QUICK-START]] — [[QUICK-START]] [[QUICK-START]] guide
- [[reference/glossary]], [[reference/commands]], [[reference/quick-commands]]
- [[software/ai-tools/commands|AI commands]]
- [[reference/lspci-reference]], [[reference/lspci-akuma-output]]
- Disk: split sde 50/50 — sde1 ext4, sde2 xfs
- Fix: auto-detect root UUID in [[toggle-p40]].sh
- Added [[system/drives-and-mounts]]
- Added [[reference/bugs-and-workarounds]]
- Added [[software/dev-setup]]
- Added [[reference/faq]]

## 2026-06-12 — CUDA 12.9, P40 VFIO

- CUDA 12.9: updated docs with GCC 14 requirement, glibc 2026 noexcept fix
- [[hardware/gpu/tesla-p40-vfio]] — Tesla P40 VFIO passthrough guide
- Toggle script reference + development bug notes

## 2026-06-11 — Steam/NVIDIA/input log

- CachyOS Steam/NVIDIA/input troubleshooting log
- [[software/kde/temporary-hacks]] — KDE#519773 workaround

## 2026-06-08 — KDE workarounds, temporary hacks

- [[software/kde/temporary-hacks]] — KDE#519773 workaround + MIME fix

## 2026-06-07 — KDE workarounds, dolphinrc

- Add [[software/kde/workarounds|tracked KDE workarounds doc]]
- Add [[software/kde/dolphin-config|dolphinrc reference config]]

## 2026-06-06 — VM-Disks partition, thorium dark mode

- Update sde → VM-Disks across all docs
- thorium-shell --force-dark-mode patch note

## 2026-06-05 — CUDA 12.4 dual-arch, P40 kernel fix

- CUDA 12.4 dual-arch build: sm_61 + sm_86 for dual GPU
- [[hardware/gpu/config-notes|P40 fix]]: kernel cmdline (not modprobe.d), power cable troubleshooting

## 2026-06-04 — Rebuild script, live-env-setup, pkglist

- Added [[system/rebuild-notes|rebuild script]] + [[live-env-setup]] + pkglist

## 2026-05-13 — Free models/providers, context index

- [[software/ai-tools/free-models]] — online model reference
- [[software/ai-tools/free-providers]] — free LLM API providers
- [[context/INDEX]] — marked CURRENT vs HISTORICAL

## 2026-05-11 — GW2 multi-box, mono/dotnet48

- [[software/gaming/gw2-multibox-wine-setup|GW2 multi-box Wine setup]]
- mono/dotnet48 failure mode and test build section

## 2026-05-10 — System memory, storage layout, rebuild notes

- [[system/system-memory]] — merged AI reference
- [[system/drives-and-mounts]] — storage layout
- [[system/rebuild-notes]]
- Distilled [[software/gaming/gw2-multibox-wine-setup|GW2 setup]] from FixBot log
- Marked stale docs historical vs current

## 2026-05-09 — Commands, quick-commands

- Added [[software/ai-tools/commands|commands]] + [[reference/quick-commands|quick-commands]]
- Added q search function
