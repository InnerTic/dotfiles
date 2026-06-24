# Storage Layout Plan for System Change

## Target Drive Layout

| Drive | Size | Mount Point | Purpose |
|-------|------|-------------|---------|
| **nvme0n1** | 465GB | `/home/ken/Steam` (library) | Steam games, heavy AI apps (llama.cpp, forge) |
| **sdb** | 120GB | `/` + `/boot` | OS - root + boot partitions |
| **sdd** | 112GB | `/home` | User configs, dotfiles, Wine prefixes, small home data |
| **sda** | 465GB | `/mnt/ssd_storage` | Bind [[drives-and-mounts]]: Documents, Downloads, Pictures, Videos |

## Rationale
- **Steam must be in /home** (or custom library path), but games go on nvme library for speed
- **Wine** puts prefixes wherever it wants (usually `~/.wine` on small `/home`)
- **AI workloads** stay on nvme for speed, outside normal OS for easy rebuild
- **Bind [[drives-and-mounts]]** keep bulk data (downloads, pics, docs) off OS [[drives-and-mounts]] = clean backups
- **Small /home** = fast to clone/backup, contains only configs and small files
- **Large data** on separate drive = not cluttering working drive

## Directory Structure After Layout

```
/ (sdb 120GB) - OS
├── boot/
└── home/ken/              (on sdd 112GB)
    ├── .config/           # App configs
    ├── .local/            # Local app data  
    ├── .openclaw/         # OpenClaw config (AI agent)
    ├── .opencode/         # OpenCode config
    ├── .wine/             # Wine prefixes
    ├── .cache/            # App caches
    ├── Steam/             # Steam files (on nvme via library path)
    └── ... (dotfiles)

/mnt/ssd_storage (sda 465GB) - Bulk Data
└── home/ken/
    ├── Documents/         # Personal docs, backups
    ├── Downloads/         # General downloads
    ├── Pictures/          # Photos, screenshots
    └── Videos/            # Video files

/nvme0n1 (465GB) - Performance
└── Steam_library/        # Steam games installed here
```

## Implementation Steps

### 1. Prepare Target Directories
```bash
sudo mkdir -p /mnt/ssd_storage/home/ken/{Documents,Downloads,Pictures,Videos}
sudo chown -R ken:ken /mnt/ssd_storage/home/ken/
```

### 2. Sync Data (when ready)
```bash
rsync -av /home/ken/Documents.backup/ /mnt/ssd_storage/home/ken/Documents/
rsync -av /home/ken/Downloads.backup/ /mnt/ssd_storage/home/ken/Downloads/
rsync -av /home/ken/Pictures.backup/ /mnt/ssd_storage/home/ken/Pictures/
rsync -av /home/ken/Videos.backup/ /mnt/ssd_storage/home/ken/Videos/
```

### 3. Create Bind Mounts
```bash
sudo mount --bind /mnt/ssd_storage/home/ken/Documents /home/ken/Documents
sudo mount --bind /mnt/ssd_storage/home/ken/Downloads /home/ken/Downloads
sudo mount --bind /mnt/ssd_storage/home/ken/Pictures /home/ken/Pictures
sudo mount --bind /mnt/ssd_storage/home/ken/Videos /home/ken/Videos
```

### 4. Add to /etc/fstab for Persistence
```
/mnt/ssd_storage/home/ken/Documents   /home/ken/Documents   none   bind   0   0
/mnt/ssd_storage/home/ken/Downloads   /home/ken/Downloads   none   bind   0   0
/mnt/ssd_storage/home/ken/Pictures    /home/ken/Pictures    none   bind   0   0
/mnt/ssd_storage/home/ken/Videos      /home/ken/Videos      none   bind   0   0
```

## Steam Setup
```bash
# Create Steam library directory on nvme
mkdir -p /home/ken/Steam

# In Steam client:
# Settings > Downloads > Steam Library Folders > Add Library Path > /home/ken/Steam
```

## What Goes Where

| Location | Drive | Why |
|----------|-------|-----|
| `/home/ken/.config`, `.local`, `.openclaw`, `.opencode`, `.wine` | sdd (112GB) | Small configs, fast access |
| `/home/ken/Steam` | nvme0n1 (465GB) | Fast game loading |
| `/home/ken/Documents`, `Downloads`, `Pictures`, `Videos` | sda (via bind mount) | Bulk data, off working drive |
| `llama.cpp`, `forge-webui` | nvme0n1 | Performance for AI |

## Backup Implications
- **Small /home** clone = fast (~112GB), configs only
- **nvme** clone = games + heavy AI (if needed)
- **ssd_storage** = music, docs, downloads, media (separate backup target)

## Quick Reference for Local AI (Recovery Setup)

If you need to tell a local AI to set this up for you, give it this document or these commands:

### "Set up the storage layout as per /home/ken/storage_layout_plan.md"

### Recovery Script (Run as Root)
```bash
#!/bin/bash
# Storage layout setup for complete rebuild
# Run this on a fresh system to restore the mount structure

STORAGE_UUID="4c2a516d-28af-43f7-9936-4157b2652582"  # sda UUID
MOUNT_BASE="/mnt/ssd_storage"

# 1. Ensure storage drive mounts at boot (add to /etc/fstab if not already)
echo "UUID=$STORAGE_UUID $MOUNT_BASE ext4 defaults 0 2" >> /etc/fstab

# 2. Create target directories
mkdir -p $MOUNT_BASE/home/ken/{Documents,Downloads,Pictures,Videos}
chown -R ken:ken $MOUNT_BASE/home/ken/

# 3. Sync data (uncomment AFTER verifying backups exist)
# rsync -av /path/to/Documents.backup/ $MOUNT_BASE/home/ken/Documents/
# rsync -av /path/to/Downloads.backup/ $MOUNT_BASE/home/ken/Downloads/
# rsync -av /path/to/Pictures.backup/ $MOUNT_BASE/home/ken/Pictures/
# rsync -av /path/to/Videos.backup/ $MOUNT_BASE/home/ken/Videos/

# 4. Add bind mounts to /etc/fstab
cat >> /etc/fstab << 'EOF'
/mnt/ssd_storage/home/ken/Documents   /home/ken/Documents   none   bind   0   0
/mnt/ssd_storage/home/ken/Downloads   /home/ken/Downloads   none   bind   0   0
/mnt/ssd_storage/home/ken/Pictures    /home/ken/Pictures    none   bind   0   0
/mnt/ssd_storage/home/ken/Videos      /home/ken/Videos      none   bind   0   0
EOF

# 5. Mount everything
mount -a

# 6. Verify
df -h /home/ken/{Documents,Downloads,Pictures,Videos}
```

### System Verification Checklist for AI
```
[ ] Check drive UUIDs: lsblk -f
[ ] Verify sda at /mnt/ssd_storage mounts
[ ] Check backup directories exist at storage mount target
[ ] Run mount -a to apply fstab entries
[ ] Verify df -h shows correct mount points
[ ] Test file access: ls /home/ken/Documents
```

### AI Prompt Template
Copy/paste this to your local AI for setup:
```
I need to configure storage drives as described in /home/ken/storage_layout_plan.md.

Drive layout:
- sda (465GB SSD) at /mnt/ssd_storage - holds bulk data (Documents, Downloads, Pictures, Videos)
- sdd (112GB SSD) at /home - user configs 
- nvme0n1 (465GB) at /home/ken/Steam - Steam library for games

Please:
1. Verify the target directories exist on /mnt/ssd_storage
2. Set up bind mounts for Documents, Downloads, Pictures, Videos to /mnt/ssd_storage
3. Add entries to /etc/fstab to persist across reboots
4. Verify everything mounts correctly

Use the layout plan at /home/ken/storage_layout_plan.md for reference.
```

---

## Desktop Environment Notes

### KDE + LXDE Setup
Default desktop is KDE. Install LXDE alongside for SDXL/Forge sessions:

```bash
# Install LXDE (lightweight, frees VRAM for AI work)
sudo pacman -S lxde

# At login (SDDM), select LXDE or KDE session
```

**When to use which:**
- **KDE** - Default for web, games, OpenClaw, normal desktop use
- **LXDE** - Only when running SDXL/Forge (long sessions, PC tied up anyway)

LXDE uses far less VRAM for desktop compositor, leaving more for AI workloads.

## Reference Documents

| Document | Location | Purpose |
|----------|----------|---------|
| KDE Settings Backup | `/home/ken/KDE_SETTINGS_BACKUP.txt` | Manual restore instructions for KDE/Plasma config files |
| Ollama Notes | `/home/ken/ollama_cpu_gpu_switch_notes.md` | GPU/CPU switching for embeddings |
| System Backup | `/home/ken/Documents/system_backup/` | Original backup checklist and rebuild script |

## Long-Term Hardware Roadmap

### Current PC (This Machine)
- RTX 3060 (12GB VRAM)
- Future: Add Tesla P40 (24GB) → 36GB total VRAM
- Use case: Quick AI queries, OpenClaw, gaming

### Future Server (ThinkServer RD430)
- **CPU**: 2x 4-[[core-baseline]] Xeon (8 cores total)
- **RAM**: 112GB
- **GPU**: 3x Tesla P40 (48GB VRAM total)
- **Storage**: Connected via network
- **OS**: Proxmox virtualization
- **Network**: Add 2.5Gb card for direct PC↔server link (server has 2x 1Gb + 1x 100Mb now)

### Network Upgrade
- Server currently: 2x 1Gb + 1x 100Mb ports
- Add: 2.5Gb network card for direct link to this PC
- Benefit: Fast model transfer, low latency AI inference

### Timeline (Approximate)
- Year-long build project (SSI budget constraints)
- Phase 1: This PC with Tesla added
- Phase 2: Server tested and ready
- Phase 3: Network upgrade (2.5Gb card)
- Phase 4: Full PC + server setup

### What 48GB VRAM Enables
- Large models (70B+ in Q4 quantization)
- SDXL + LLM simultaneously
- Multiple model slots loaded
- No VRAM juggling during sessions

---
*Layout based on user requirements for clean OS separation. Last updated: 2026-04-19*