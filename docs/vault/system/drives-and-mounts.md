---
tags: [system, storage, reference]
aliases: [drives, mounts, fstab, storage-layout]
updated: 2026-06-15
---

# Drives & Mounts

**Drift assessment (2026-07-11):** Drive letter assignments differ between MX Linux and CachyOS boots. UUIDs are static but mount points may vary. Dual-boot — verify `lsblk` on the active OS before trusting letter assignments.

Physical drive layout, UUIDs, fstab entries, bind mounts, and symlinks.

## Drive Inventory

| Drive | Size | FS | Mount | Purpose |
|-------|------|----|-------|---------|
| **sdb1** | 465G | ext4 | `/mnt/ssd_storage` | Bulk data — documents, downloads, media |
| **sdc1** | 3.6T | btrfs | `/mnt/m2_storage` | M.2 storage |
| **sdd2** | 222G | ext4 | `/` (root) | OS root (rootMX25, Debian 13 trixie) |
| **sdd3** | 243G | xfs | USB mount | USB drive |
| **sdf1** | 3.6T | btrfs | `/media/HDD_Data` | Model storage (GGUFs), backups, large files |
| **nvme0n1p1** | 465G | ext4 | `/mnt/workspace` | AI tools, llama.cpp, forge, projects (persistent) |

## UUIDs (for /etc/fstab) — CachyOS current state

| Mount | UUID | Drive | Notes |
|-------|------|-------|-------|
| / | `76c0155f-a646-40b6-8fec-ae64fcc4a037` | sda2 (btrfs) | CachyOS root |
| /boot | `C3E7-93C2` | sda1 (vfat) | `nofail` |
| /home | `e070aea8-a128-4e6d-9e3f-da38a6604dbe` | sdd1 (btrfs) | `nofail` |
| /mnt/ssd_storage | `51b4243d-ea88-4a02-b02f-c286d52b6e0d` | sdb1 (ext4) | Bind-mounted into ~/ |
| /mnt/data | `f0b1d710-a0a6-4ef1-83ce-fc9e55d577d8` | sdc1 (btrfs) | 3.6T HDD-Data |
| /mnt/workspace | `9a1cdd8a-3d81-468f-be70-aa00a01d7301` | nvme0n1p1 (ext4) | NVMe, persists reinstalls |

> **Drift from MX Linux vault doc**: Drive letters differ between CachyOS and MX Linux boots.
> CachyOS uses sda for boot/root, sdd for /home — MX Linux used different letters.
> VM storage (sde4) and dual-boot partitions (sde2/3) are on a USB-connected ADATA SSD and are NOT in fstab (auto-mounted by udisks2 when connected).

## Drive Selection Guide (CachyOS)

| Use case | Drive | Why |
|----------|-------|-----|
| OS, packages, temp | sda (/) | CachyOS root, btrfs subvolumes |
| AI models, projects | nvme (workspace) | Fast NVMe, persists reinstalls |
| Model GGUFs (canonical) | sdc (/mnt/data) | 3.6T HDD-Data |
| Documents, media | sdb (ssd_storage) | Large SSD, bind-mounted to ~/ |
| Gaming/VM storage | sde4 (USB SSD) | External ADATA, not in fstab |

## Bind Mounts (/etc/fstab)

ssd_storage directories bind-mounted into home for media and data:

| Source | Target |
|--------|--------|
| `/mnt/ssd_storage/ken/Documents` | `/home/ken/Documents` |
| `/mnt/ssd_storage/ken/Downloads` | `/home/ken/Downloads` |
| `/mnt/ssd_storage/ken/Pictures` | `/home/ken/Pictures` |
| `/mnt/ssd_storage/ken/Videos` | `/home/ken/Videos` |
| `/mnt/ssd_storage/ken/Desktop` | `/home/ken/Desktop` |
| `/mnt/ssd_storage/ken/Music` | `/home/ken/Music` |
| `/mnt/ssd_storage/ken/go` | `/home/ken/go` |
| `/mnt/ssd_storage/ken/MEGA` | `/home/ken/MEGA` |

## Symlinks in ~/

| Symlink | Target | Purpose |
|---------|--------|---------|
| `~/ssd_storage` | `/mnt/ssd_storage` | Quick access to bulk storage |
| `~/workspace` | `/mnt/workspace` | Primary work directory |
| `/workspace` | `/mnt/workspace` | Steam Proton Z: drive compat |
| `~/Models` | `~/Downloads/llm_models` | Shortcut to model files |
| `~/Gw2-win` | `/mnt/ssd_storage/ken/Gw2-win` | GW2 install |

## Workspace Persistence

`/mnt/workspace` (nvme-workspace) is the **only drive that never gets formatted**.
It holds:
- [[workspace-symlink-strategy|Symlinked home dirs]] (.ssh, .librewolf, .opencode, etc.)
- `dotfiles/` — this repo
- `llama.cpp/` — build + source
- `sd-webui-forge-neo/` — Stable Diffusion
- `textgen/` — TextGen WebUI
- `searxng/` — search engine
- Model files
- VM disk images (on sde3)

## Related

- [[reference/lspci-akuma-output]] — PCI topology showing which drives are on which bus
- [[reference/workspace-symlink-strategy]] — What lives on workspace and how it's linked into /home
