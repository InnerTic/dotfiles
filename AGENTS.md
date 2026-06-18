# dotfiles — Portable Linux user environment

Host **Akuma** (Debian 13 / CachyOS dual-boot, KDE Plasma 6, dual GPU).  
Not a Node.js/app project — ignore npm/playwright/prisma boilerplate.

## Bootstrap

```bash
git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Symlinks: `shell/.zshrc` → `~/.zshrc`, `shell/config.fish` → `~/.config/fish/config.fish`, `git/.gitconfig` → `~/.gitconfig`, `ssh/config` → `~/.ssh/config`.

## Quick Ref

| What | Command |
|------|---------|
| Start Forge | `sdxl` |
| Start Hermes | `llmstart` |
| Kill Hermes | `llmk` |
| Model picker | `llama-loader` |
| Health check | `healthcheck` |

## GPU Setup

- **RTX 3060** (sm_86, 12GB) — GPU 0
- **Tesla P40** (sm_61, 24GB) — GPU 1, needs `CUDA_VISIBLE_DEVICES=1` for isolation
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"`
- Hermes (20B) on P40 port 8080

## Key Docs

| File | Content |
|---|---|
| `docs/INDEX.md` | Vault root index |
| `docs/rebuild/debian-setup-hoops.md` | All Debian gotchas |
| `docs/rebuild/rebuild-notes.md` | Session records |
| `docs/gpu/gpu-config-notes.md` | Dual-GPU layout |
| `docs/reference/commands.txt` | Full command reference |
| `docs/system_backup/REBUILD_SCRIPT.sh` | Master rebuild |
| `docs/vault/projects/translation-pipeline.md` | Pipeline v2.0 |

## Rules

- **Model inventory**: scan disk before assigning models — filenames drift. `find ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'`
- **GPU cap**: RTX 3060 ≈9GB, P40 ≈20GB after overhead. MoE does NOT save VRAM in llama.cpp.

## Appendix: Installation Protocol

When installing software, document every step in `docs/reference/` for reproducibility:

- Full commands with all flags (copy/paste ready)
- Annotations explaining why each step exists (gotchas, edge cases, why not the obvious approach)
- Source URLs / references for anything fetched
- Config files in full (not diffs — complete blocks)
- Service files, env vars, directory layout
- Verification commands to confirm it works

The goal: a clean OS reinstall should be fully recoverable from these docs + the dotfiles repo — no tribal knowledge required.
