#!/bin/bash
# Debian
# =============================================================================
# SYSTEM REBUILD SCRIPT (Debian)
# Run this after OS reinstall/storage change to restore your AI setup
# CURRENT as of 2026-06-15 — textgen bundled llama-server + P40 ready
# Usage: source REBUILD_SCRIPT.sh
# =============================================================================

echo "============================================================================"
echo "  SYSTEM REBUILD SCRIPT (Debian)"
echo "============================================================================"
echo ""
echo "Prerequisites:"
echo "  1. Install Debian 13 (Trixie) with standard partitioning"
echo "  2. Clone dotfiles (deb branch):"
echo "     git clone -b deb git@github.com:InnerTic/dotfiles.git ~/dotfiles"
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

sudo apt update
sudo apt install -y \
  ntfs-3g btrfs-progs xfsprogs \
  build-essential cmake git

if [[ -f ~/dotfiles/docs/system_backup/pkglist-apps.txt ]]; then
  echo "  Installing app packages from pkglist-apps.txt..."
  grep -v '^\s*#' ~/dotfiles/docs/system_backup/pkglist-apps.txt | grep -v '^\s*$' | sudo xargs apt install -y 2>/dev/null || true
fi

# =============================================================================
# STEP 2: Add persistent drives to fstab
# =============================================================================
echo ""
echo "=== STEP 2: Adding drives to /etc/fstab (nofail = safe to boot if missing)..."

if grep -q 'UUID=51b4243d' /etc/fstab 2>/dev/null; then
  echo "  fstab entries already present, skipping."
else
  sudo tee -a /etc/fstab << 'FSTAB'

# ssd_storage (sdb)
UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d /mnt/ssd_storage ext4 defaults,nofail 0 2
# Data-HDD (sdc) — ntfs-3g must be installed first
UUID=7E303CAF303C6FEF /mnt/data ntfs-3g defaults,nofail,uid=1000,gid=1000,umask=000 0 2
# VM-Disks (sde3) — xfs, VM disk storage
UUID=81132c1e-5ca5-419f-8967-61284c27dadd /mnt/vm-disks xfs defaults,nofail 0 2
# nvme-workspace (nvme0n1p1)
UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301 /mnt/workspace ext4 defaults,nofail 0 2
# m2_storage (sdd)
UUID=e070aea8-a128-4e6d-9e3f-da38a6604dbe /mnt/m2_storage btrfs defaults,nofail 0 2

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
fi

sudo mkdir -p /mnt/{ssd_storage,data,m2_storage,workspace}
sudo mkdir -p /home/ken/{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}
sudo mount -a

echo "  Drives mounted. Verify: df -h | grep /mnt"

# =============================================================================
# STEP 3: Symlinks
# =============================================================================
echo ""
echo "=== STEP 3: Creating symlinks..."
rm -rf ~/ssd_storage ~/m2_storage ~/workspace ~/Models
ln -sf /mnt/ssd_storage ~/ssd_storage
ln -sf /mnt/m2_storage ~/m2_storage
ln -sf /mnt/workspace ~/workspace
sudo ln -sf /mnt/workspace /workspace
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
    echo "  Clone: git clone -b deb git@github.com:InnerTic/dotfiles.git ~/dotfiles"
fi

if [[ -f ~/dotfiles/bootstrap.sh ]]; then
    echo "  Running dotfiles bootstrap..."
    cd ~/dotfiles && bash bootstrap.sh
fi

echo ""
echo "=== STEP 4b: Setting up Oh My Zsh & plugins..."
if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "  Oh My Zsh already installed"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

if [[ ! -d $ZSH_CUSTOM/themes/powerlevel10k ]]; then
  echo "  Installing powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

if [[ ! -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ]]; then
  echo "  Installing zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

if [[ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]]; then
  echo "  Installing zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

echo "  Source: source ~/.zshrc (after installs complete)"
echo "  Zsh setup done."

# =============================================================================
# STEP 5: Check CUDA and llama.cpp
# =============================================================================

echo ""
echo "=== STEP 5: CUDA setup..."
echo "  CUDA layout:"
echo "    - NVIDIA driver from debian non-free (nvidia-driver metapackage)"
echo "    - GPU 0: RTX 3060 (sm_86) → SDXL / diffusion"
echo "    - GPU 1: Tesla P40 (sm_61) → llama.cpp inference"
echo ""

echo "  Checking NVIDIA driver..."
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null
  echo "  ✓ NVIDIA driver installed"
else
  echo "  ✗ NVIDIA driver not found. Install with:"
  echo "    sudo apt install nvidia-driver firmware-misc-nonfree"
  echo "    Then reboot"
fi

echo ""
echo "  Checking llama.cpp build..."
if [[ -f /mnt/workspace/llama.cpp/build-cuda12/bin/llama-server ]]; then
  echo "  ✓ llama.cpp build-cuda12 exists"
  echo "  Note: This was built on Arch (glibc 2.43) and may not run on Debian (glibc 2.41)."
  echo "  Using textgen bundled llama-server instead."
fi

echo ""
echo "  Checking textgen bundled llama-server..."
TEXTGEN_BIN="/mnt/workspace/textgen/venv/lib/python3.13/site-packages/llama_cpp_binaries/bin"
if [[ -f "$TEXTGEN_BIN/llama-server" ]]; then
  echo "  ✓ textgen bundled llama-server found"
else
  echo "  ✗ Not found — install textgen-webui first (see step 8)"
fi

# =============================================================================
# STEP 6: Install Forge WebUI
# =============================================================================
echo ""
echo "=== STEP 6: Installing SD WebUI Forge Neo..."
if [[ -d /mnt/workspace/sd-webui-forge-neo/.git ]]; then
  echo "  Forge already cloned, updating..."
  cd /mnt/workspace/sd-webui-forge-neo && git pull
else
  git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git /mnt/workspace/sd-webui-forge-neo
fi
echo "  ✓ Forge ready. First launch will install dependencies automatically."
echo "  Run: cd /mnt/workspace/sd-webui-forge-neo && python3 launch.py --listen"

# =============================================================================
# STEP 7: Restore GGUF models
# =============================================================================
echo ""
echo "=== STEP 7: Restore GGUF models..."
if ls ~/Downloads/llm_models/*.gguf >/dev/null 2>&1; then
    echo "  ✓ $(ls ~/Downloads/llm_models/*.gguf 2>/dev/null | wc -l) models present"
else
    echo "  ✗ No models found. Restore from backup to ~/Downloads/llm_models/"
fi

# =============================================================================
# STEP 8: Install textgen-webui
# =============================================================================
echo ""
echo "=== STEP 8: Install TextGen WebUI (if not present)..."
if [[ -d /mnt/workspace/textgen/.git ]]; then
  echo "  ✓ textgen already cloned"
else
  echo "  Clone and install textgen-webui:"
  echo "    cd /mnt/workspace"
  echo "    git clone https://github.com/oobabooga/text-generation-webui.git textgen"
  echo "    cd textgen"
  echo "    ./start_linux.sh --listen"
  echo "  (First run installs CUDA-enabled llama-cpp-python)"
fi

# =============================================================================
# STEP 9: Verify Scripts
# =============================================================================
echo ""
echo "=== STEP 9: Verify Scripts..."
for script in ~/.local/bin/llama-loader \
              ~/dotfiles/scripts/llama-server.sh \
              ~/dotfiles/scripts/forge-start.sh; do
    if [[ -f $script ]]; then
        echo "  ✓ $(basename $script)"
    else
        echo "  ✗ $script MISSING"
    fi
done

for script in ~/.openclaw/workspace/scripts/llama-start.sh \
              ~/.openclaw/workspace/scripts/textgen-start.sh; do
    if [[ -f $script ]]; then
        echo "  ✓ $(basename $script)"
    else
        echo "  ✗ $script MISSING"
    fi
done

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
echo "  ocl / oclw       - opencode TUI/Web with local models"
echo "  textgen          - Start TextGen WebUI (port 7861)"
echo "  forge            - Start SD Forge (port 7860)"
echo ""
echo "Full ref:     ~/dotfiles/docs/commands.txt"
echo "LLaMA setup:  ~/dotfiles/docs/llama-setup.md"
echo "Context:      ~/dotfiles/docs/context/system-memory.md"
