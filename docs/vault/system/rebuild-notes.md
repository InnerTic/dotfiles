# Rebuild Notes

## Session 2026-06-18 — OpenCode/OpenClaw + Dual-Boot Recovery

### System State (Current)
- **Debian 13 (Trixie)** on sde (476G MX Linux install)
- **CachyOS** on sda (119G, btrfs) — still intact, sda1 has Limine EFI
- Dual-boot: Limine (sda1) as primary boot manager, GRUB (sde1) for MX/Debian
- P40 (GPU 1, sm_61) + RTX 3060 (GPU 0, sm_86)

### OpenCode/OpenClaw Configuration
- **Local provider**: `custom-127-0-0-1-8080` → alias `local-oss-20` (Hermes on port 8080)
- **Online provider**: `opencode` with `big-pickle` model (free, Zen API key)
- Default model: `opencode/big-pickle`
- Key lesson: models go in `models.providers["opencode"].models[]` not just `agents.defaults.models` — "Unknown model" error otherwise
- Config file: `~/.openclaw/openclaw.json`
- API key in `~/.zshrc` as `OPENCODE_ZEN_API_KEY`

### Hermes 20B Server
- **Model**: `gpt-oss-20b-hermes.Q5_K_M.gguf` (16GB, 20.9B params, 131K context)
- **GPU**: P40 via `CUDA_VISIBLE_DEVICES=1`
- **Port**: 8080
- **Performance**: ~13 t/s
- **Runner**: local llama.cpp build at `/mnt/workspace/llama.cpp/build/bin/llama-server`

### CUDA GPU Isolation
- `--main-gpu 1` does NOT prevent model loading on GPU 0
- Must use `CUDA_VISIBLE_DEVICES=1` for true P40 isolation
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"` (P40 + RTX 3060)

### PromptEnhancer-32B
- Extension installed in Forge Neo at `/mnt/workspace/sd-webui-forge-neo/extensions/PromptEnhancer-32B/`
- Runs on P40 via `CUDA_VISIBLE_DEVICES=1` in [[forge-start]].sh
- Wildcards directory active
- Custom extension (separate from existing forge extensions which use local HF models)

### Forge Neo Python 3.13 Fixes
- `requirements_versions.txt`: sed `s/==/>=/g` then selective re-pinning
- Pins: `gradio==4.40.0`, `huggingface-hub<0.25`, `diffusers==0.31.0`, `transformers==4.46.1`, `peft==0.13.2`
- Launch: `--skip-python-version-check --skip-torch-cuda-test --medvram --theme dark`

### ChatGPT Export
- 70MB export, 121 conversations parsed
- Split to `~/Documents/chatlogs/chatgpt/`
- OpenClaw trajectories (6 sessions) → `~/Documents/chatlogs/openclaw/`
- Other chats → `~/Documents/chatlogs/other/`
- All chatlogs gitignored

### Drive Layout (Current)
- `sda` — 119G: sda1=vfat (C3E7-93C2, Limine EFI), sda2=btrfs (CachyOS)
- `sde` — 476G: sde1=vfat (3F33-0777, MX EFI), sde2=ext4 (rootMX25, Debian 13)

### Key Commands Reference
```bash
# Start Hermes on P40
CUDA_VISIBLE_DEVICES=1 /mnt/workspace/llama.cpp/build/bin/llama-server \
  -m ~/Downloads/llm_models/gpt-oss-20b-hermes.Q5_K_M.gguf \
  --port 8080 --host 0.0.0.0 -ngl 99 -c 131072

# Start Forge
~/dotfiles/scripts/forge-start.sh
```

## Session 2026-05-10

## Storage Layout
- `/mnt/ssd_storage` — sdb1 (ssd_storage, ext4, 465G) [[drives-and-mounts]] UUID=51b4243d-ea88-4a02-b02f-c286d52b6e0d
- `/mnt/data` — sdc2 (Data-HDD, ntfs-3g, 3.6T) [[drives-and-mounts]] UUID=7E303CAF303C6FEF
- `/mnt/m2_storage` — sde1 (m2_storage, btrfs, 476G) [[drives-and-mounts]] UUID=6befefdd-f232-4757-9eea-9f7051da3c0b
- `/mnt/workspace` — nvme0n1p1 (nvme-workspace, ext4, 465G) [[drives-and-mounts]] UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301

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
See `docs/gaming/gw2-multibox-wine-setup.md` for the full Wine/Proton setup. Key requirements:
- `/workspace` symlink must exist (Z: drive path for Proton prefixes)
- Two physical GW2 installs on separate [[drives-and-mounts]]
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
