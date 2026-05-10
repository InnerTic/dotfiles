# Storage Layout Implementation Workflow
# Canoncial workflow from chat with Monday Kitsune (2026-04-19)

## PHASE 1: PREPARATION (DO NOT RUN - REVIEW ONLY)

### 1. Verify current drive layout
lsblk -f  # Shows UUIDs and mount points

### 2. Backup critical AI configurations (DO THIS FIRST)
mkdir -p ~/backups
tar -czvf ~/backups/openclaw_dotfiles.tar.gz ~/.openclaw ~/.opencode
cp -r ~/.openclaw/workspace/memory ~/backups/memory_backup/

### 3. Create target directories on storage SSD (sda)
sudo mkdir -p /mnt/ssd_storage/home/ken/{Documents,Downloads,Pictures,Videos}
sudo chown -R $USER:$USER /mnt/ssd_storage/home/ken/


## PHASE 2: DATA MIGRATION (REVIEW)

### 4. Sync existing data to storage SSD (run one at a time to verify)
rsync -av --progress ~/Documents.backup/ /mnt/ssd_storage/home/ken/Documents/
rsync -av --progress ~/Downloads.backup/ /mnt/ssd_storage/home/ken/Downloads/
rsync -av --progress ~/Pictures.backup/ /mnt/ssd_storage/home/ken/Pictures/
rsync -av --progress ~/Videos.backup/ /mnt/ssd_storage/home/ken/Videos/

### 5. Verify sync worked
ls -la /mnt/ssd_storage/home/ken/Documents/ | head -5


## PHASE 3: BIND MOUNT SETUP (REVIEW)

### 6. Move current user folders to backup locations
sudo mv ~/Documents ~/Documents.bak
sudo mv ~/Downloads ~/Downloads.bak
sudo mv ~/Pictures ~/Pictures.bak
sudo mv ~/Videos ~/Videos.bak

### 7. Create new empty mount points
sudo mkdir ~/Documents ~/Downloads ~/Pictures ~/Videos

### 8. Create bind mounts (requires sudo)
sudo mount --bind /mnt/ssd_storage/home/ken/Documents ~/Documents
sudo mount --bind /mnt/ssd_storage/home/ken/Downloads ~/Downloads
sudo mount --bind /mnt/ssd_storage/home/ken/Pictures ~/Pictures
sudo mount --bind /mnt/ssd_storage/home/ken/Videos ~/Videos

### 9. Verify mounts working
df -h ~/Documents ~/Downloads ~/Pictures ~/Videos


## PHASE 4: PERSISTENT CONFIGURATION (REVIEW)

### 10. Get drive UUIDs for /etc/fstab
lsblk -f  # Look for sda

### 11. Add to /etc/fstab for persistence (requires sudo)
# Replace UUID_HERE with actual sda UUID
echo "UUID=UUID_HERE /mnt/ssd_storage ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/mnt/ssd_storage/home/ken/Documents /home/ken/Documents none bind 0 0" | sudo tee -a /etc/fstab
echo "/mnt/ssd_storage/home/ken/Downloads /home/ken/Downloads none bind 0 0" | sudo tee -a /etc/fstab
echo "/mnt/ssd_storage/home/ken/Pictures /home/ken/Pictures none bind 0 0" | sudo tee -a /etc/fstab
echo "/mnt/ssd_storage/home/ken/Videos /home/ken/Videos none bind 0 0" | sudo tee -a /etc/fstab

### 12. Test fstab by unmounting and remounting
sudo umount ~/Documents ~/Downloads ~/Pictures ~/Videos
sudo mount -a


## PHASE 5: AI WORKSPACE SETUP (REVIEW)

### 13. Create workspace on NVMe
sudo mkdir -p /home/ken/workspace
sudo chown -R $USER:$USER /home/ken/workspace

### 14. Move OpenClaw workspace to NVMe
openclaw gateway stop
mv ~/.openclaw/workspace /home/ken/workspace/.openclaw

### 15. Update OpenClaw config to point to new workspace
# Edit ~/.openclaw/openclaw.json: "workspace": "/home/ken/workspace"

### 16. Create steam logs symlink
ln -sf ~/.steam/logs /home/ken/workspace/steam_logs

### 17. Build llama.cpp in workspace (when ready)
cd /home/ken/workspace
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
mkdir build && cd build
cmake .. -DLLAMA_CUBLAS=ON
make -j$(nproc)


## PHASE 6: BACKUP STRATEGY (REVIEW)

### 18. Set up mega.nz backup
yay -S mega-cmd  # or paru -S mega-cmd

### 19. Configure mega.cmd with megarc for non-interactive auth
# Create ~/.megarc with credentials

### 20. Set up backup commands
# Live sync:
tar -czvf ~/mega-sync/openclaw_backup_latest.tar.gz ~/.openclaw ~/.opencode

# Archived snapshots:
tar -czvf ~/mega-sync/openclaw_archive_$(date +%F).tar.gz ~/.openclaw ~/.opencode


## CRITICAL POINTS

- Test one directory at a time - start with Documents only
- Keep backups until verified - don't delete .bak until sure
- Verify Ollama embeddings before removing - test llama.cpp first
- System Python stays clean - each AI tool gets own venv
- OpenClaw/OpenCode configs are irreplaceable - back these up religiously