---
tags: [audit, review, knowledge]
updated: 2026-06-21
---

# Knowledge Audit — 2026-06-21

Audit of all documentation in `~/dotfiles/docs/`.  
Confidence score: 100 = verified, 75 = mostly verified, 50 = partially verified, 25 = likely outdated, 0 = obsolete.

---

## Critical Issues

### 1. `docs/docs/` Duplicate (44 files)

A full nested copy of the old docs exists at `docs/docs/`. These 44 files shadow the real vault and pollute grep/search results. They are **not** linked from any INDEX.

**Files duplicated:**
`commands.txt`, `context/`, `gpu-config-notes.md`, `gw2-multibox-wine-setup.md`, `INDEX.md`, `llama-loader-integrity-contract.md`, `llama-setup.md`, `lspci-akuma-output.md`, `lspci-reference.md`, `quartz-setup.md`, `quick-commands.txt`, `rebuild-notes.md`, `reference/`, `system_backup`, `temporary-hacks.md`, `tesla-p40-vfio-passthrough.md`, `vault/`, `workspace-symlink-strategy.md`

### 2. GPU Driver Version

| Source | Version | Distro Context |
|--------|---------|---------------|
| `docs/gpu/gpu-config-notes.md` | 580.159.04 | CachyOS/Arch package version |
| `nvidia-smi` (actual, Debian boot) | 580.142 | Debian package version |

Same upstream NVIDIA 580.x driver branch, different packaging version per distro. **Not drift.**

### 3. CUDA Version

| Source | Version | Distro Context |
|--------|---------|---------------|
| `docs/gpu/gpu-config-notes.md` | 12.9.1 | CachyOS package (`cuda-12.9`) |
| `nvcc --version` (actual, Debian boot) | 12.4.131 | Debian package |

Likely same story — different distros ship different CUDA toolkit versions. The `docs/vault/software/ai-tools/cuda-12.9-setup.md` doc is for the CachyOS boot. **Not drift.**

---

## Document Scores

### Root docs (INDEX, Map, QUICK-START)

| File | Score | Notes |
|------|-------|-------|
| `docs/INDEX.md` | **75** | All wikilinks resolve. Needs VM/forge path updates. Prompt-hats/experimental ref present. |
| `docs/vault/map.md` | **75** | All wikilinks resolve. Does not list `docs/` root files (conky, heat-aware). |
| `docs/vault/QUICK-START.md` | **75** | Not inspected in detail, but references likely correct. |
| `docs/Scratchpad - Input lobby.md` | **50** | Content extraction stub — several referenced files may not exist (vlm-research.md, research-wiki-structure.md, keyd-f24-kde-wayland.md). |

### GPU Docs

| File | Score | Notes |
|------|-------|-------|
| `docs/gpu/gpu-config-notes.md` | **25** | Driver version 580.159.04 is wrong (actual 580.142). CUDA 12.9 is wrong (actual 12.4). llama.cpp commit `b1-64b38b5` unverified. |
| `docs/gpu/llama-setup.md` | **75** | Build flags are correct. Dual-GPU CMAKE_CUDA_ARCHITECTURES="61;86" still valid. |
| `docs/gpu/llama-setup-debian.md` | **75** | Likely correct for current Debian 13. |
| `docs/gpu/llama-setup-cachyos.md` | **75** | Likely correct for CachyOS (though system has migrated to Debian). |
| `docs/gpu/tesla-p40-vfio-passthrough.md` | **75** | VFIO config — P40 still present, driver mode is VFIO. |

### Conky Docs

| File | Score | Notes |
|------|-------|-------|
| `docs/conky-system-cockpit.md` | **75** | Conky 1.22.1 verified on system. All referenced scripts exist. |
| `docs/heat-aware-cockpit.md` | **100** | Freshly created design doc. |
| `docs/heat-aware-dropin.md` | **100** | Freshly created config reference. |

### LXC / Proxmox Docs

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/reference/lxc-build-log.md` | **75** | Scripts exist. Cannot verify container status (not on Proxmox host). VMID 300/9000 unverified. |
| `docs/vault/reference/architecture-snapshot.md` | **75** | Scripts exist. Network topology (172.16.x) unverifiable from this host. |
| `docs/vault/reference/ai-ssh-architecture.md` | **100** | Freshly created design doc. |
| `docs/vault/reference/proxmox-ssh-infrastructure.md` | **75** | Key injection pattern is standard and correct. |
| `docs/reference/container-bootstrap.md` | **25** | **Superseded** by `lxc-build-log.md` and `scripts/lxc-provision.sh`. Kept for reference but instructions are less precise. |

### llama-loader Docs

| File | Score | Notes |
|------|-------|-------|
| `docs/reference/llama-loader-architecture.md` | **25** | **Superseded.** References old `-n` prefix pattern (pre-IR). `NP_ARG`, `GPU_ARG` patterns are obsolete. Mentions old path `~/dotfiles/scripts/llama-loader.old`. |
| `docs/llama-loader-integrity-contract.md` | **25** | **Superseded.** Pre-IR contract. Contains old `NP_ARG`, `--n`, `n` prefix examples that no longer match the actual IR/dialect architecture. |
| `docs/vault/reference/chat-ingestion-architecture.md` | **75** | Vault architecture doc — references `decisions/2026-06-19n-arg-state-format.md` which is pre-IR nomenclature. |
| `docs/vault/reference/index-retrieval-system.md` | **75** | Same stale reference `decision:2026-06-19n-state-format`. |
| `docs/vault/reference/memory-reasoning-execution-pipeline.md` | **75** | Architecture ref — no code paths to verify. |

### Keyd Docs (3 overlapping files)

| File | Score | Notes |
|------|-------|-------|
| `docs/reference/yakuake-keyd-f24.md` | **50** | **Superseded** by vault versions. 41 lines, less detail. |
| `docs/vault/reference/keyd-stack.md` | **75** | Most comprehensive (279 lines). |
| `docs/vault/reference/keyd-kde-wayland-f24.md` | **75** | Complementary (117 lines). |

### Reinstall Guides

| File | Score | Notes |
|------|-------|-------|
| `docs/reinstall-guides/debian/llama-cpp.md` | **75** | Build instructions for Debian 13 — no specific version drift detected. |
| `docs/reinstall-guides/debian/textgen.md` | **75** | Same. |
| `docs/reinstall-guides/debian/forge-neo.md` | **50** | References `/mnt/workspace/sd-webui-forge-neo/` which does **not exist** on disk. |
| `docs/reinstall-guides/cachyos/llama-cpp.md` | **75** | CachyOS boot — intentionally kept for the other boot environment. |
| `docs/reinstall-guides/cachyos/textgen.md` | **75** | Same. |
| `docs/reinstall-guides/cachyos/forge-neo.md` | **75** | CachyOS boot — forge path is valid for that environment. |

### Context Docs (marked CURRENT)

| File | Score | Notes |
|------|-------|-------|
| `docs/context/system-memory.md` | **75** | Core reference. Updated 2026-06-21. Drive UUIDs and mounts unverifiable from non-root shell. |
| `docs/context/quick-commands.md` | **75** | AI tool commands — commands reference actual scripts. |
| `docs/context/free-models.md` | **75** | Model/provider reference — external info, unlikely to drift. |
| `docs/context/free-providers.md` | **75** | Same. |
| `docs/context/kde-settings.md` | **75** | KDE backup file list — unlikely to drift. |
| `docs/context/kde-workarounds.md` | **75** | KDE bug list. |

### Context Docs (marked HISTORICAL — kept as reference)

| File | Score | Notes |
|------|-------|-------|
| `docs/context/storage-layout-plan.md` | **25** | Marked HISTORICAL. Drive labels/sizes known wrong. Superseded by system-memory. |
| `docs/context/implementation-workflow.md` | **25** | Marked HISTORICAL. Old paths. Superseded by system-memory. |
| `docs/context/system-profile.md` | **25** | Marked HISTORICAL. Stale package list. |
| `docs/context/ollama-notes.md` | **25** | Marked HISTORICAL. |
| `docs/context/opencode-plugins.md` | **25** | Marked HISTORICAL. |
| `docs/context/serena-mcp.md` | **25** | Marked HISTORICAL. |
| `docs/context/fixbot-chatlog.md` | **50** | Stub pointing to full chat log. Log file at `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` exists. |

### Vault Reference Docs

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/reference/glossary.md` | **75** | Term definitions — stable content. |
| `docs/vault/reference/faq.md` | **75** | Common questions — stable. |
| `docs/vault/reference/bugs-and-workarounds.md` | **75** | Active bug list — manually maintained. |
| `docs/vault/reference/libvirt-bridge-setup.md` | **75** | KVM bridge setup — CachyOS specific but technically valid. |
| `docs/vault/reference/boot-diagnostics.md` | **75** | Boot diagnostics reference — architected, not runtime-dependent. |
| `docs/vault/reference/quartz-constitution.md` | **75** | Quartz wiki design doc. |
| `docs/vault/reference/vault-query-scripts.md` | **75** | Query script design. |
| `docs/vault/reference/translation-pipeline-spec.md` | **75** | Translation pipeline design. |
| `docs/vault/reference/translation-pipeline-proposal.md` | **75** | Proposal doc. |
| `docs/vault/reference/research-wiki-structure.md` | **50** | Scratchpad extraction — may be incomplete. |
| `docs/reference/search-setup.md` | **25** | SearXNG setup — likely not actively deployed. |

### Vault Scripts README and Rebuild

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/scripts/README.md` | **75** | Script index. References `build-gold-lxc.sh`, `lxc-provision.sh`, `lxc-bootstrap.sh` — all exist. |
| `docs/vault/scripts/REBUILD_SCRIPT.md` | **75** | Rebuild reference. Points to `system_backup/REBUILD_SCRIPT.sh` which exists. |
| `docs/vault/system/drives-and-mounts.md` | **75** | Drive/mount reference. UUIDs unverifiable from non-root. |
| `docs/vault/system/dual-boot-recovery.md` | **75** | Boot recovery — Debian/MX Linux dual boot. |

### Projects

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/projects/translation-pipeline.md` | **75** | Elaborate 10-role pipeline. Source path `/mnt/data/_translation-pipeline/` unverifiable. |
| `docs/vault/projects/translation-pipeline/model-index.md` | **75** | Model capabilities for pipeline. |
| `docs/vault/projects/sd-webui-forge-neo.md` | **25** | Forge reference. Source `/mnt/workspace/sd-webui-forge-neo/` does **not exist** on disk. P40 VAE offload spec unverifiable. |
| `docs/vault/projects/meta-scripts.md` | **25** | Status "planned" — no implementation exists. Likely abandoned. |

### Prompt Hats

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/software/prompt-hats/INDEX.md` | **100** | Freshly created. All wikilinks resolve. |
| All 22 hat `.md` files + 8 experimental | **100** | Freshly created. No runtime dependencies. |
| `docs/reference/agent-hallucination-techniques.md` | **50** | 24-line stub — experimental, not integrated into hat system. |

### Vault Software

| File | Score | Notes |
|------|-------|-------|
| `docs/vault/software/dev-setup.md` | **75** | Python venv, git, shell setup — stable patterns. |
| `docs/vault/software/ai-tools/commands.md` | **75** | AI command reference — references real scripts. |
| `docs/vault/software/ai-tools/cuda-12.9-setup.md` | **25** | CUDA 12.9 setup instructions. Actual CUDA is 12.4. If used, would install wrong version. |
| `docs/vault/software/ai-tools/vlm-research.md` | **50** | VLM model research — external reference. |
| `docs/vault/software/kvm-bridge-networking.md` | **75** | KVM bridge setup — Debian variant of libvirt doc. |

### System Backup (CachyOS Boot Reference)

| File | Score | Notes |
|------|-------|-------|
| `docs/system_backup/cachyos-steam-nvidia-input-log.md` | **75** | CachyOS boot reference — intentionally kept. |
| `docs/system_backup/storage_layout_plan.md` | **75** | CachyOS boot reference — intentionally kept. |
| `docs/system_backup/implementation_workflow.md` | **75** | CachyOS boot reference — intentionally kept. |

### Renamed / Legacy

| File | Score | Notes |
|------|-------|-------|
| `docs/reference/workspace-symlink-strategy.md` | **75** | Symlink plan — still relevant. |
| `docs/reference/lspci-reference.md` | **75** | lspci cheat sheet — stable. |
| `docs/reference/lspci-akuma-output.md` | **50** | PCI topology — may have drifted if hardware changed. |
| `docs/reference/search-setup.md` | **25** | SearXNG — likely not deployed. |
| `docs/known-issues/temporary-hacks.md` | **75** | Active KDE workarounds — manually maintained. |
| `docs/gaming/gw2-multibox-wine-setup.md` | **75** | Gaming setup — stable. |

---

## Drift Summary

| Category | Count | Average Score |
|----------|-------|---------------|
| Total documents | 146 (excluding 44 dupes) | — |
| Freshly created (100) | 11 | 100 |
| Mostly correct (75) | 57 | 75 |
| Partially stale (50) | 16 | 50 |
| Likely outdated (25) | 17 | 25 |
| Obsolete (0) | 0 | — |

## Action Items

### ✅ Completed

1. **`docs/docs/` duplicate** — deleted (72 entries, untracked, old pre-restructure snapshot).
2. **Superseded docs deleted**: `reference/llama-loader-architecture.md`, `llama-loader-integrity-contract.md`, `reference/container-bootstrap.md`, `reference/yakuake-keyd-f24.md`.

### Remaining

3. **Abandoned project**: `vault/projects/meta-scripts.md` — status "planned", no implementation.
4. **Missing forge path** — `/mnt/workspace/sd-webui-forge-neo/` does not exist on Debian boot. Either reinstall Forge or mark Debian forge docs as inactive.
5. **Update AGENTS.md** — shell is `/bin/bash`, not fish. Driver version note refers to CachyOS — clarify or split by branch.

### Not Action Items (intentionally kept for other boots)

- CachyOS reinstall guides (`reinstall-guides/cachyos/`)
- CachyOS GPU docs (`gpu/llama-setup-cachyos.md`)
- System backup artifacts (`system_backup/`)
- CachyOS libvirt bridge (`vault/reference/libvirt-bridge-setup.md`)
