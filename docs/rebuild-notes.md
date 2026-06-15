# Rebuild Notes — 2026-05-10

## Storage Layout
- `/mnt/ssd_storage` — sdb1 (ssd_storage, ext4, 465G) fstab UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d
- `/mnt/data` — sdc2 (Data-HDD, ntfs-3g, 3.6T) fstab UUID=7E303CAF303C6FEF
- `/mnt/m2_storage` — sde1 (m2_storage, btrfs, 476G) fstab UUID=6befefdd-f232-4757-9eea-9f7051da3c0b
- `/mnt/workspace` — nvme0n1p1 (nvme-workspace, ext4, 465G) fstab UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301

## Bind Mounts (in /etc/fstab)
| Source | Target |
|--------|--------|
| /mnt/ssd_storage/ken/Documents | /home/ken/Documents |
| /mnt/ssd_storage/ken/Downloads | /home/ken/Downloads |
| /mnt/ssd_storage/ken/Pictures | /home/ken/Pictures |
| /mnt/ssd_storage/ken/Videos | /home/ken/Videos |
| /mnt/ssd_storage/ken/Desktop | /home/ken/Desktop |
| /mnt/ssd_storage/ken/Music | /home/ken/Music |
| /mnt/ssd_storage/ken/go | /home/ken/go |
| /mnt/ssd_storage/ken/MEGA | /home/ken/MEGA |

## Symlinks in ~/
- `~/ssd_storage` -> /mnt/ssd_storage
- `~/m2_storage` -> /mnt/m2_storage
- `~/workspace` -> /mnt/workspace
- `~/Models` -> ~/Downloads/llm_models
- `~/Gw2-win` -> /mnt/ssd_storage/ken/Gw2-win (Guild Wars 2, Steam install pending)

## Shell Config
- .zshrc now includes history dedup options (HIST_IGNORE_DUPS etc.)
- HISTSIZE=10000 / SAVEHIST=10000
- Powerlevel10k theme, Oh My Zsh

## What Was Removed
- Broken `games` symlink from ~/
- AnythingLLMDesktop.AppImage (3.7GB, on ssd_storage/ken/)
- Duplicate Steam Proton prefix for GW2 (app 1284210) created May 10 on ssd_storage

## System File Patches (apply after install)

```bash
# Thorium Shell — add dark mode support
sudo sed -i 's|/opt/thorium-browser/thorium_shell |/opt/thorium-browser/thorium_shell --force-dark-mode |' /usr/bin/thorium-shell
```

## GW2 Multi-Box
See `docs/gw2-multibox-wine-setup.md` for the full Wine/Proton setup. Key requirements:
- `/workspace` symlink must exist (Z: drive path for Proton prefixes)
- Two physical GW2 installs on separate drives
- NVIDIA GPU must be forced, AMD iGPU crashes
- Two AppIDs: 1284210 (primary, Steam) and 2716098372 (second, non-Steam)

## Drives
- `sda` — OS root (119G, Btrfs subvolumes)
- `sdb` — ssd_storage (465G, ext4)
- `sdc` — Data-HDD (3.6T, NTFS)
- `sdd` — ssd_home (112G, Btrfs) mounted at /home
- `sde1` — Future-OS (238G, ext4, Limine) noauto
- `sde2` — VM-Disks (238G, xfs) at /mnt/vm-disks
- `nvme0n1` — nvme-workspace (465G, ext4)
