---
tags: [system, storage, reference]
aliases: [drives, mounts, fstab, storage-layout]
updated: 2026-06-15
---

# Drives & Mounts

Physical drive layout, UUIDs, fstab entries, bind mounts, and symlinks.

## Drive Inventory

| Drive | Size | FS | Mount | Purpose |
|-------|------|----|-------|---------|
| **sda** | 119G | btrfs | `/` | OS root (subvolumes: root, boot, var, swap) |
| **sdb** | 465G | ext4 | `/mnt/ssd_storage` | Bulk data — documents, downloads, media |
| **sdc** | 3.6T | ntfs | `/mnt/data` | Long-term backup, large files |
| **sdd** | 112G | btrfs | `/home` | User home dir (ephemeral — wiped on reinstall) |
| **sde1** | 238G | ext4 | — | Future OS (Limine bootloader) |
| **sde2** | 238G | xfs | `/mnt/vm-disks` | VM disk storage |
| **nvme0n1** | 465G | ext4 | `/mnt/workspace` | AI tools, models, projects, dotfiles (persistent) |

## UUIDs (for /etc/fstab)

| Mount | UUID |
|-------|------|
| sda root | `acaebe11-05e0-48d5-957e-7b35f21f73fb` |
| sda boot | `7193-39A8` |
| sdd /home | `4365b1fa-735e-455d-9645-e65be9903454` |
| sdb /mnt/ssd_storage | `51b4243d-ea88-4a02-b02f-c286d52b6e0d` |
| sdc /mnt/data | `7E303CAF303C6FEF` |
| sde1 /mnt/new-os | `9e04d3b5-745c-49b9-bdec-e865672eb2a0` (ext4, noauto) |
| sde2 /mnt/vm-disks | `9e63ef79-7b4a-4511-a4d5-d411a59af195` (xfs) |
| nvme /mnt/workspace | `9a1cdd8a-3d81-468f-be70-aa00a01d7301` |

## Drive Selection Guide

| Use case | Drive | Why |
|----------|-------|-----|
| OS, packages, temp | sda (/) | Btrfs snapshots for rollback |
| AI models, projects | nvme (workspace) | Fast NVMe, persists reinstalls |
| Documents, media | sdb (ssd_storage) | Large SSD, bind-mounted to ~/ |
| VMs, disk images | sde2 (VM-Disks) | Dedicated xfs partition |
| Future OS install | sde1 (new-os) | ext4, noauto in fstab — mount when needed |
| Backups, archives | sdc (Data-HDD) | 3.6T NTFS, slow but huge |
| User configs | sdd (/home) | Small btrfs, gets wiped |

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
- VM disk images (on sde2)

## Related

- [[lspci-akuma-output]] — PCI topology showing which drives are on which bus
- [[workspace-symlink-strategy]] — What lives on workspace and how it's linked into /home
