# System Memory — Akuma

**Drift assessment (2026-06-23):** This file was restored from old vault (8bd2b5f). System is dual-boot (Debian 13 + CachyOS). Sections annotated with which OS they apply to. Verify drive letters per-OS before trusting any path or UUID.

## Host Info

| Field | Value | Drift |
|-------|-------|-------|
| Host | Akuma | STATIC |
| OS | Debian 13 Trixie | DUAL-BOOT — Debian 13 + CachyOS; this doc covers Debian layout |
| CPU | Ryzen 7 5700G (16 cores) | STATIC |
| RAM | 48 GiB (46.3 GiB usable) | STATIC |
| GPU | RTX 3060 12GB + AMD Radeon integrated | STATIC |
| Driver | 580.142 | DUAL-BOOT — 580.142 (Debian) / 580.159.04 (CachyOS) |
| P40 status | CUDA-accessible | **STALE** — P40 is VFIO-bound on current boot, verify per-OS |

## Drive Layout (MX Linux, 2026-07-11)

| Drive | Size | FSType | Mount | Purpose |
|-------|------|--------|-------|---------|
| **sdb1** | 465.8G | ext4 | `/mnt/ssd_storage` | Bulk data (docs, downloads, pics, videos) |
| **sdc1** | 3.6T | btrfs | `/mnt/m2_storage` | M.2 storage |
| **sdd2** | 222.7G | ext4 | `/` (root) | OS root (rootMX25, Debian 13 trixie) |
| **sdd3** | 243.5G | xfs | USB mount | USB drive |
| **sdf1** | 3.6T | btrfs | `/media/HDD_Data` | Model storage (GGUFs), backups, large files |
| **nvme0n1p1** | 465.8G | ext4 | `/mnt/workspace` | AI tools, llama.cpp, forge, projects |

## OS Subvolumes (sda, Btrfs) — Debian layout; CachyOS subvol layout may differ

`/`, `/root`, `/srv`, `/var/cache`, `/var/tmp`, `/var/log`, `/boot` (vfat), swap

## Symlinks in ~/ — STALE (verify existence, especially /workspace and Gw2-win)

```
~/ssd_storage  -> /mnt/ssd_storage          # CURRENT — exists
# ~/m2_storage   -> /mnt/m2_storage          # DEPRECATED — does not exist
~/workspace    -> /mnt/workspace             # STALE — /workspace symlink may not exist
~/Models       -> ~/Downloads/llm_models     # CURRENT — exists
~/Gw2-win      -> /mnt/ssd_storage/ken/Gw2-win # STALE — does not exist
```

## Bind Mounts (/etc/fstab) — Debian boot; CachyOS should match via dotfiles bootstrap

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

## UUIDs (for /etc/fstab) — Debian boot UUIDs; CachyOS may assign different drive letters; UUIDs themselves are static

| Mount | UUID |
|-------|------|
| sdd2 / (root) | 34bdf920-237c-4392-835f-0416be09ada5 |
| sdd1 /boot/efi | 3F33-0777 (vfat) |
| sdb1 /mnt/ssd_storage | 51b4243d-ea88-4a02-b02f-c286d52b6e0d |
| sdc1 /mnt/m2_storage | e070aea8-a128-4e6d-9e3f-da38a6604dbe |
| sdf1 /media/HDD_Data | f0b1d710-a0a6-4ef1-83ce-fc9e55d577d8 |
| nvme /mnt/workspace | 9a1cdd8a-3d81-468f-be70-aa00a01d7301 |

## AI Tool Aliases (from ~/.zshrc) — Debian boot; CachyOS uses fish, paths may differ (`~/dotfiles/scripts/` and `~/.local/bin/`). Scripts should consolidate to `~/.local/bin/` regardless of OS.

### llama.cpp (local models on port 8080)
| Alias | Command |
|-------|---------|
| `llm` | `llama-loader` — interactive model selector |
| `llmk` | `kill-llama` — kill [[llama-server]] |
| `llmcheck` | `curl -s http://127.0.0.1:8080/v1/models \| jq -r .data[].id` |
| `llmstart` | `~/.openclaw/workspace/scripts/llama-start.sh` |

Models in `~/Downloads/llm_models/` (.gguf). GPU offload: `-ngl 35` (7B-8B fits 12GB VRAM).

**Models on disk differ from old listings** — see [[software/ai-tools/free-models]] for current inventory.

### SDXL/Forge (sd-webui-forge-neo, port 7860) — Debian paths; CachyOS alias: `sdxl` = `~/workspace/sd-webui-forge-neo/`
| Alias | Command |
|-------|---------|
| `sdxl` | `~/.openclaw/workspace/scripts/forge-start.sh` |
| `sdxlkill` | `pkill -f "launch.py\|webui.py"` |
| URL | `http://172.16.5.1:7860` |

### TextGen WebUI (port 7861) — Debian paths; CachyOS alias: `textgen` = `~/workspace/textgen/`
| Alias | Command |
|-------|---------|
| `textgen` | `~/.openclaw/workspace/scripts/textgen-start.sh` |
| `textkill` | `pkill -f "server.py"` |
| URL | `http://172.16.5.1:7861` (Web) / `:5000` (API) |

### OpenClaw — Debian paths; may differ on CachyOS
| Alias | Command |
|-------|---------|
| `openclaw tui` | Start TUI |
| `openclaw dashboard` | Browser dashboard |
| `openclaw status` | Check status |
| `openclaw gateway restart` | Restart gateway |
| Webchat | `http://172.16.5.1:18789` |

### OpenCode — Debian paths; CachyOS aliases in AGENTS.md
| Alias | Command |
|-------|---------|
| `oc` | `opencode` |
| `ocl` | `~/.openclaw/workspace/scripts/opencode-local.sh tui` |
| `oclw` | `~/.openclaw/workspace/scripts/opencode-local.sh web` |

### OpenClaw Model Switching — model names likely outdated; verify against actual disk contents
```
# Cloud (Favorites):
/model Favorites/big-pickle            # Primary
/model Favorites/gpt-5-nano            # Backup

# OpenRouter Free Fallbacks:
/model OpenRouter/openrouter/auto
/model OpenRouter/nvidia/nemotron-nano-9b-v2:free
/model OpenRouter/openai/gpt-oss-20b:free

# Local (requires llama-server on 8080):
/local/qwen2.5-7b, /local/qwen3.5-4b, /local/phi-4-mini
```

## GW2 Multi-Boxing Essentials — CURRENT (last used for GW2 setup, likely still valid)

- **2 physical installs** on separate [[drives-and-mounts]] (ssd_storage + nvme-workspace)
- **2 AppIDs**: 1284210 (primary/Steam), 2716098372 (second/non-Steam)
- **Must force NVIDIA**: `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia`
- **Strip LD_PRELOAD**: `LD_PRELOAD=""` (Steam overlay causes ELFCLASS32/64)
- **`/workspace` symlink must exist** (Z: drive in Proton prefixes)
- **GE-Proton10-32** was the working Proton version
- **`-shareArchive`** flag for shared Gw2.dat access
- **Known crash (ntdll.dll 80000100)**: isolated physical copies fix overlay cache conflicts
- See `gw2-multibox-wine-setup.md` for full details

## Ollama GPU/CPU Switch — CURRENT (generic Ollama config, tool behavior is static)

```
# GPU mode (default): ollama serve
# CPU mode: OLLAMA_DISABLE_GPU=1 ollama serve
# VRAM limit: OLLAMA_MAX_LOADED_MODELS=1
# Parallel limit: OLLAMA_NUM_PARALLEL=2
```

OpenClaw uses Ollama for embeddings: model `embeddinggemma:latest`.

## Network — verify IPs; LXC wiki at 172.16.12.17 not listed

| Device | IP |
|--------|----|
| Akuma PC | 172.16.5.1 |
| ZimaBoard (DNS/ad-block) | 172.16.1.1 |
| ppihole (ZimaBoard LAN) | 172.16.12.1 |
| MikroTik Switch | 172.16.88.1 |

## Dotfiles Repo

- `git@github.com:InnerTic/dotfiles.git`
- Bootstrap: `cd ~/dotfiles && ./bootstrap.sh`
- Shell: Zsh + Powerlevel10k + Oh My Zsh, `HISTSIZE=10000`

## KDE/Plasma Restore

Backup KDE configs from `~/.config/` before rebuild. Key files: `kdeglobals`, `kwinrc`, `kwinoutputconfig.json`, `dolphinrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kglobalshortcutsrc`, `kdeconnect/`. See `kde-settings.md` for full restore command.

## Python

Always use venv — never system Python. `pip freeze > requirements.txt`.

## Key Scripts Directory

`~/.openclaw/workspace/scripts/` — contains `llama-start.sh`, `forge-start.sh`, `textgen-start.sh`, `opencode-local.sh`, `mega-push.sh`, `mega-pull.sh`.

## Backup Strategy

- MEGA via rclone (`~/.local/bin/rclone`)
- Push: `~/.openclaw/workspace/scripts/mega-push.sh`
- Pull: `~/.openclaw/workspace/scripts/mega-pull.sh`
- pihole backup (cron, 3am): `/Backups/pihole-configs/` on MEGA

## System File Patches (not in dotfiles)

| File | Patch | Reason |
|------|-------|--------|
| `/usr/bin/thorium-shell` | Added `--force-dark-mode` | Dark mode not available otherwise |

## Rebuild Quick-Ref

```bash
# After fresh install:
cd ~/dotfiles && ./bootstrap.sh
sudo ln -sf /mnt/workspace ~/workspace
# Restore KDE configs from backup (see kde-settings.md)
# Reinstall packages from package-list.txt via pacman -S
# Reinstall AUR packages via yay/paru
# Set up bind mounts (see fstab entries above)
# Apply system file patches (see "System File Patches" section above)
```
