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
echo ""
echo "  !!! NVIDIA DRIVER CONFLICT WARNING !!!"
echo "  If you have a Tesla P40 (or any non-standard NVIDIA card) installed,"
echo "  PHYSICALLY REMOVE IT before installing the OS. The CachyOS installer"
echo "  auto-installs the default nvidia package (610xx) which will conflict"
echo "  with the 580xx series needed for older cards. Installing over the"
echo "  conflict breaks the driver stack and requires a reinstall."
echo "  Reinstall the card after the OS is booted, then run this script."
echo ""
echo "  === VFIO: isolate the Tesla P40 from nvidia driver ==="
echo "  The P40 on the PCIe bus causes nvidia driver hangs when its"
echo "  auxiliary power is disconnected (idles at ~47W vs 3060's 14W)."
echo "  VFIO isolation fixes this and lets you bind it on demand."
echo ""
echo "  1. Add vfio modules to initramfs:"
echo "    sudo sed -i 's/^MODULES=()/MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)/' /etc/mkinitcpio.conf"
echo ""
echo "  2. Create /etc/modprobe.d/vfio.conf:"
echo "    sudo tee /etc/modprobe.d/vfio.conf <<'EOF'"
echo "    options vfio-pci ids=10de:1b38"
echo "    softdep nvidia pre: vfio-pci"
echo "    softdep nvidia_drm pre: vfio-pci"
echo "    softdep nvidia_modeset pre: vfio-pci"
echo "    EOF"
echo ""
echo "  3. Append to kernel cmdline (/etc/default/limine for Limine):"
echo "    Append 'vfio-pci.ids=10de:1b38' to KERNEL_CMDLINE[default]"
echo ""
echo "  4. Rebuild and reboot:"
echo "    sudo mkinitcpio -P && sudo limine-update && reboot"
echo ""
echo "  After reboot, verify: lspci -nnk -s 04:00.0"
echo "  Should show 'Kernel driver in use: vfio-pci'"
echo "  To use P40 for CUDA later, unbind vfio-pci and bind nvidia."
echo ""
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
  base-devel cmake



if [[ -f ~/dotfiles/docs/system_backup/pkglist-apps.txt ]]; then
  echo "  Installing app packages from pkglist-apps.txt..."
  sed '/^\s*#/d; /^\s*$/d' ~/dotfiles/docs/system_backup/pkglist-apps.txt | sudo pacman -S --needed -
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
UUID=7E303CAF303C6FEF /mnt/data ntfs-3g defaults,nofail 0 2
# VM-Disks (sde1) — reformatted from btrfs to xfs
UUID=446695a8-1348-4d45-ab10-5af0a5bf1ae5 /mnt/vm-disks xfs defaults,nofail 0 2
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
fi

sudo mkdir -p /mnt/{ssd_storage,data,vm-disks,workspace}
sudo mkdir -p /home/ken/{Documents,Downloads,Pictures,Videos,Desktop,Music,go,MEGA}
sudo mount -a

echo "  Drives mounted. Verify: df -h | grep /mnt"

# =============================================================================
# STEP 3: Symlinks
# =============================================================================
echo ""
echo "=== STEP 3: Creating symlinks..."
rm -rf ~/ssd_storage ~/m2_storage ~/vm-disks ~/workspace ~/Models
ln -sf /mnt/ssd_storage ~/ssd_storage
ln -sf /mnt/vm-disks ~/vm-disks
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

# OpenClaw completions
if [[ ! -f ~/.openclaw/completions/openclaw.zsh ]]; then
  echo "  OpenClaw completions not found — install openclaw first"
  echo "  See: https://openclaw.ai/docs/install"
fi

echo "  Source: source ~/.zshrc (after installs complete)"

echo "  Zsh setup done."

# =============================================================================
# STEP 5: Build llama.cpp (system CUDA 12.9, dual GPU: sm_61 + sm_86)
# =============================================================================

echo ""
echo "=== STEP 5: Building llama.cpp with CUDA 12.9 (sm_61 + sm_86)..."
echo "  Build location: /mnt/workspace/llama.cpp"
echo ""

echo "  CUDA layout:"
echo "    - /opt/cuda (CUDA 12.9 AUR package)"
echo "    - GPU 0: RTX 3060 (sm_86) → SDXL / diffusion"
echo "    - GPU 1: Tesla P40 (sm_61) → llama.cpp inference"
echo ""

# -----------------------------------------------------------------------------
# Ensure CUDA exists
# -----------------------------------------------------------------------------
echo "  Checking CUDA..."
if ! command -v nvcc >/dev/null 2>&1; then
  echo "  CUDA not found. Install with:"
  echo "    paru -S cuda-12.9"
  exit 1
fi

nvcc --version

# -----------------------------------------------------------------------------
# Use persistent workspace
# -----------------------------------------------------------------------------
echo ""
echo "  Using workspace: /mnt/workspace"

cd /mnt/workspace

if [[ -d llama.cpp ]]; then
  echo "  llama.cpp exists → updating"
  cd llama.cpp
  git pull
else
  echo "  cloning llama.cpp"
  git clone https://github.com/ggerganov/llama.cpp.git
  cd llama.cpp
fi

# -----------------------------------------------------------------------------
# Configure build
# -----------------------------------------------------------------------------
echo ""
echo "  Configuring build..."
echo "  Note: nvcc may warn about sm_61 deprecation (P40). This is harmless."

rm -rf build-cuda12

cmake -S . -B build-cuda12 \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="61;86" \
  -DCUDAToolkit_ROOT=/opt/cuda

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
echo ""
echo "  Building llama.cpp..."
cmake --build build-cuda12 -j$(nproc)

echo ""
echo "  DONE"
echo "  Binary: /mnt/workspace/llama.cpp/build-cuda12/bin/"

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
