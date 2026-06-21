# dotfiles — Portable Linux user environment

Host **Akuma** (Debian 13 / CachyOS dual-boot, KDE Plasma 6, dual GPU).  
Default shell: **bash** (Debian) / **fish** (CachyOS) — AI aliases defined in all three configs (.bashrc, .zshrc, config.fish).  
Not a Node.js/app project — ignore npm/playwright/prisma boilerplate.

Repo split: `dotfiles.git` (this repo) for user env, `vault.git` for knowledge, `infra.git` for automation.

## Bootstrap

```bash
git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Symlinks: `shell/.bashrc` → `~/.bashrc`, `shell/.zshrc` → `~/.zshrc`, `shell/config.fish` → `~/.config/fish/config.fish` (CachyOS only), `git/.gitconfig` → `~/.gitconfig`, `ssh/config` → `~/.ssh/config`.

## Quick Ref

| What | Command | Defined In |
|------|---------|------------|
| Start Forge | `sdxl` | `~/.local/bin/forge-start` (infra.git) |
| Start Hermes | `llmstart` | `.bashrc`/`.zshrc`/`config.fish` |
| Kill Hermes | `llmk` | `.bashrc`/`.zshrc`/`config.fish` |
| Model picker | `llama-loader` | `~/.local/bin/llama-loader` → infra.git |
| Health check | `healthcheck` | infra.git/services/healthcheck.sh |

## GPU Setup

- **RTX 3060** (sm_86, 12GB) — GPU 0
- **Tesla P40** (sm_61, 24GB) — GPU 1, needs `CUDA_VISIBLE_DEVICES=1` for isolation
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"`
- Hermes (20B) on P40 port 8080
- GPU driver 580.159.04 (CachyOS) vs 580.142 (Debian) — same upstream 580.x branch, distro packaging variant only. CUDA 12.9 (CachyOS) vs 12.4 (Debian) — intentional per-distro versions.
- `nvidia-smi` calls must use `--id=0` to isolate RTX 3060 from P40

## Key Docs

| Repo | File | Content |
|---|---|---|
| vault.git | `docs/INDEX.md` | Vault root index |
| vault.git | `docs/vault/system/debian-setup-hoops.md` | All Debian gotchas |
| vault.git | `docs/vault/system/rebuild-notes.md` | Session records |
| vault.git | `docs/vault/hardware/gpu/config-notes.md` | Dual-GPU layout |
| vault.git | `docs/vault/reference/commands.md` | Full command reference |
| vault.git | `docs/vault/scripts/REBUILD_SCRIPT.sh` | Master rebuild |
| vault.git | `docs/vault/projects/translation-pipeline.md` | Pipeline v2.0 |

## Rules

- **Model inventory**: scan disk before assigning models — filenames drift. `find ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'`
- **GPU cap**: RTX 3060 ≈9GB, P40 ≈20GB after overhead. MoE does NOT save VRAM in llama.cpp.

## Appendix: Installation Protocol

When installing software, document every step in `vault.git` (`docs/vault/`) for reproducibility:

- Full commands with all flags (copy/paste ready)
- Annotations explaining why each step exists (gotchas, edge cases, why not the obvious approach)
- Source URLs / references for anything fetched
- Config files in full (not diffs — complete blocks)
- Service files, env vars, directory layout
- Verification commands to confirm it works

The goal: a clean OS reinstall should be fully recoverable from these docs + the dotfiles repo — no tribal knowledge required.
