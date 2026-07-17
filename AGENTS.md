# dotfiles — Portable Linux user environment (MIRROR)

Vault-centric architecture: `vault.git` is the sole source of truth.
This repo (`dotfiles.git`) is a **read-only mirror** synced from `vault/dotfiles/`.

Host **Akuma** (Debian 13 / CachyOS dual-boot, KDE Plasma 6, dual GPU).  
Default shell: **bash** (Debian) / **fish** (CachyOS) — AI aliases defined in all three configs (.bashrc, .zshrc, config.fish).  
Source of truth: `~/vault/dotfiles/`  →  mirror `~/dotfiles/`

## Bootstrap

```bash
# Source of truth
git clone git@github.com:InnerTic/vault.git ~/vault

# Mirror for system consumption
git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Symlinks: `shell/.bashrc` → `~/.bashrc`, `shell/.zshrc` → `~/.zshrc`, `shell/config.fish` → `~/.config/fish/config.fish` (CachyOS), `git/.gitconfig` → `~/.gitconfig`, `ssh/config` → `~/.ssh/config`.  
Scripts at `scripts/` are mirrored from `vault/dotfiles/scripts/` — also deployable via `~/infra/` (mirror of the same source).

**CachyOS bootstrap** (fish default): `cd ~/vault/dotfiles && ./bootstrap-arch.sh`

## OS Sync (Dual-Boot: Debian 13 ↔ CachyOS)

After editing aliases, SSH configs, or [[quick-commands]] in vault:
```bash
cd ~/vault && git pull                    # get latest on THIS OS
~/vault/dotfiles/dotfiles-sync.sh --force # push vault → dotfiles mirror
```
Then boot into the **other OS** and run the same two commands.  
Symlinks take care of the rest — no manual file copying needed.

## Quick Ref

| What | Command | Source |
|------|---------|--------|
| Start TextGen | `textgen` | `vault/dotfiles/scripts/textgen-start.sh` |
| Start Forge | `sdxl` | `vault/dotfiles/scripts/forge-start.sh` |
| Start [[llama-server]] | `llmstart` | `vault/dotfiles/scripts/llama-server.sh` |
| Forge LLM (port 8081) | `llsd` | `vault/dotfiles/scripts/forge-llm.sh` |
| Kill [[llama-server]] | `llmk` | `.bashrc`/`.zshrc`/`config.fish` |
| Model picker | `llama-loader` | `vault/dotfiles/scripts/llama-loader/llama-loader.sh` |
| Health check | `healthcheck` | `vault/dotfiles/scripts/healthcheck.sh` |

## GPU Setup

- **RTX 3060** (sm_86, 12GB) — GPU 0
- **Tesla P40** (sm_61, 24GB) — GPU 1, needs `CUDA_VISIBLE_DEVICES=1` for isolation
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"`
- Hermes (20B) on P40 port 8080
- GPU driver 580.159.04 (CachyOS) vs 580.142 (Debian) — same upstream 580.x branch, distro packaging variant only. CUDA 12.9 (CachyOS) vs 12.4 (Debian) — intentional per-distro versions.
- `nvidia-smi` calls must use `--id=0` to isolate RTX 3060 from P40

## Key Docs (vault.git)

| File | Content |
|---|---|
| `docs/INDEX.md` | Vault root index |
| `docs/vault/system/debian-setup-hoops.md` | All Debian gotchas |
| `docs/vault/system/rebuild-notes.md` | Session records |
| `docs/vault/hardware/gpu/config-notes.md` | Dual-GPU layout |
| `docs/vault/reference/commands.md` | Full command reference |
| `docs/vault/scripts/REBUILD_SCRIPT.sh` | Master rebuild |
| `docs/vault/projects/translation-pipeline.md` | Pipeline v2.0 |

## Rules

- **Model inventory**: scan disk before assigning models — filenames drift. `find ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'`
- **GPU cap**: RTX 3060 ≈9GB, P40 ≈20GB after overhead. MoE does NOT save VRAM in llama.cpp.

## Appendix: Installation Protocol

When installing software, document every step in `~/vault/docs/vault/` for reproducibility:

- Full commands with all flags (copy/paste ready)
- Annotations explaining why each step exists (gotchas, edge cases, why not the obvious approach)
- Source URLs / references for anything fetched
- Config files in full (not diffs — complete blocks)
- Service files, env vars, directory layout
- Verification commands to confirm it works

The goal: a clean OS reinstall should be fully recoverable from `vault.git` — the single source of truth.
