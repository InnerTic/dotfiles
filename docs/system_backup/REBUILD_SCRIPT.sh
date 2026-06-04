#!/bin/zsh
# =============================================================================
# SYSTEM REBUILD SCRIPT
# Run this after OS reinstall/storage change to restore your AI setup
# CURRENT as of 2026-06-04 — standalone llama.cpp + P40 ready
# Usage: source REBUILD_SCRIPT.sh
# =============================================================================

echo "============================================================================"
echo "  SYSTEM REBUILD SCRIPT"
echo "============================================================================"
echo ""
echo "Prerequisites:"
echo "  1. Boot with CachyOS ISO, install with btrfs + snapshots"
echo "  2. Clone dotfiles & run: git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles"
echo "  3. See ~/dotfiles/docs/llama-setup.md for CUDA/cmake build steps"
echo ""
echo -n "Continue? (y/n): "
read confirm

if [[ $confirm != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

# =============================================================================
# STEP 1: Install packages BEFORE touching fstab
# =============================================================================
echo ""
echo "=== STEP 1: Installing system packages..."

sudo pacman -S --needed \
  ntfs-3g btrfs-progs \
  base-devel cmake cuda

# Install app packages from list (CachyOS defaults already present)
# File: ~/dotfiles/docs/system_backup/pkglist-apps.txt
# Edit that file to add/remove apps, this step just reads it
if [[ -f ~/dotfiles/docs/system_backup/pkglist-apps.txt ]]; then
  echo "  Installing app packages from pkglist-apps.txt..."
  sudo pacman -S --needed - < ~/dotfiles/docs/system_backup/pkglist-apps.txt
fi

# =============================================================================
# STEP 2: Add persistent drives to fstab
# =============================================================================
echo ""
echo "=== STEP 2: Adding drives to /etc/fstab (nofail = safe to boot if missing)..."

sudo tee -a /etc/fstab << 'FSTAB'

# ssd_storage (sdb)
UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d /mnt/ssd_storage ext4 defaults,nofail 0 2
# Data-HDD (sdc) — ntfs-3g must be installed first
UUID=7E303CAF303C6FEF /mnt/data ntfs-3g defaults,nofail 0 2
# m2_storage (sde)
UUID=6befefdd-f232-4757-9eea-9f7051da3c0b /mnt/m2_storage btrfs defaults,nofail 0 2
# nvme-workspace (nvme0n1p1)
UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301 /mnt/workspace ext4 defaults,nofail 0 2

# Bind mounts (silently skip if source drive not mounted)
/mnt/ssd_storage/ken/Documents /home/ken/Documents none bind,nofail 0 0
/mnt/ssd_storage/ken/Downloads /home/ken/Downloads none bind,nofail 0 0
/mnt/ssd_storage/ken/Pictures /home/ken/Pictures none bind,nofail 0 0
/mnt/ssd_storage/ken/Videos /home/ken/Videos none bind,nofail 0 0
/mnt/ssd_storage/ken/Desktop /home/ken/Desktop none bind,nofail 0 0
/mnt/ssd_storage/ken/Music /home/ken/Music none bind,nofail 0 0
/mnt/ssd_storage/ken/go /home/ken/go none bind,nofail 0 0
/mnt/ssd_storage/ken/MEGA /home/ken/MEGA none bind,nofail 0 0
FSTAB

sudo mkdir -p /mnt/{ssd_storage,data,m2_storage,workspace}
sudo mkdir -p /home/ken/{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}
sudo mount -a

echo "  Drives mounted. Verify: df -h | grep /mnt"

# =============================================================================
# STEP 3: Symlinks
# =============================================================================
echo ""
echo "=== STEP 3: Creating symlinks..."
ln -sf /mnt/ssd_storage ~/ssd_storage
ln -sf /mnt/m2_storage ~/m2_storage
ln -sf /mnt/workspace ~/workspace
ln -sf ~/Downloads/llm_models ~/Models
echo "  Done."

# =============================================================================
# STEP 4: Restore dotfiles & Zsh
# =============================================================================
echo ""
echo "=== STEP 4: Restore dotfiles..."
if [[ -d ~/dotfiles ]]; then
    echo "  dotfiles already cloned"
else
    echo "  Clone: git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles"
fi

if [[ -f ~/dotfiles/bootstrap.sh ]]; then
    echo "  Running dotfiles bootstrap..."
    cd ~/dotfiles && zsh bootstrap.sh
fi

echo "  Source: source ~/.zshrc"

# =============================================================================
# STEP 5: Build llama.cpp (standalone CUDA)
# =============================================================================
echo ""
echo "=== STEP 5: Building llama.cpp with CUDA..."
echo "  See ~/dotfiles/docs/llama-setup.md for full steps"
echo ""
echo "  cd ~/workspace"
echo "  git clone https://github.com/ggerganov/llama.cpp.git"
echo "  cd llama.cpp && mkdir build && cd build"
echo "  cmake .. -DLLAMA_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=\"61;86\""
echo "  make -j\$(nproc)"
echo ""

# =============================================================================
# STEP 6: Restore GGUF models
# =============================================================================
echo ""
echo "=== STEP 6: Restore GGUF models..."
if ls ~/Downloads/llm_models/*.gguf >/dev/null 2>&1; then
    echo "  ✓ $(ls ~/Downloads/llm_models/*.gguf 2>/dev/null | wc -l) models present"
else
    echo "  ✗ No models found. Restore from backup to ~/Downloads/llm_models/"
fi

# =============================================================================
# STEP 7: Verify Scripts
# =============================================================================
echo ""
echo "=== STEP 7: Verify Scripts..."
for script in ~/.local/bin/llama-loader; do
    if [[ -f $script ]]; then
        echo "  ✓ $(basename $script)"
    else
        echo "  ✗ $script MISSING (should be in dotfiles)"
    fi
done

for script in ~/.openclaw/workspace/scripts/llama-start.sh \
              ~/.openclaw/workspace/scripts/forge-start.sh \
              ~/.openclaw/workspace/scripts/textgen-start.sh; do
    if [[ -f $script ]]; then
        echo "  ✓ $(basename $script)"
    else
        echo "  ✗ $script MISSING"
    fi
done

# =============================================================================
# STEP 8: Start Services
# =============================================================================
echo ""
echo "=== STEP 8: Starting Services..."
echo ""
echo "  # Start local AI model (interactive selector)"
echo "  llm"
echo ""
echo "  # Start web UIs"
echo "  forge-start.sh      # SDXL Forge (port 7860)"
echo "  textgen-start.sh    # TextGen (port 7861)"
echo ""
echo "  # Verify"
echo "  llmcheck            # curl localhost:8080/v1/models | jq"
echo "  curl localhost:7860 # Forge"

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "============================================================================"
echo "  BUILD CHECKLIST COMPLETE"
echo "============================================================================"
echo ""
echo "Quick commands:"
echo "  llm              - Interactive model selector (llama-loader)"
echo "  llmcheck         - Verify what's running"
echo "  oc               - opencode CLI"
echo "  ocl / oclw       - opencode-local.sh (tui/web)"
echo ""
echo "Full ref:     ~/dotfiles/docs/commands.txt"
echo "LLaMA setup:  ~/dotfiles/docs/llama-setup.md"
echo "Context:      ~/dotfiles/docs/context/system-memory.md"
