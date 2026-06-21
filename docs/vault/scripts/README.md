# Scripts Vault

All scripts extracted from monoliths, organized by purpose.

## Reinstall (numbered order)

| # | Script | Purpose | Depends On |
|---|--------|---------|------------|
| 1 | [[fstab-bind-mounts\|fstab-bind-mounts.sh]] | Add mount points and bind mounts to /etc/fstab | — |
| 2 | [[migrate-home-data\|migrate-home-data.sh]] | Copy user data (configs, SSH, etc.) from backup | (1) mounts active |
| 3 | [[symlink-workspace\|symlink-workspace.sh]] | Create workspace symlinks on SSD storage | (1) mounts active |
| 4 | [[package-install\|package-install.sh]] | Install packages via pacman/apt | — |
| 5 | [[bootstrap\|bootstrap.sh]] | Symlink dotfiles configs into ~/.config/ | (3) symlinks in place |
| 6 | [[shell-setup\|shell-setup.sh]] | Install Oh My Zsh + plugins | (5) .zshrc linked |
| 7 | [[install-tide-meslo\|install-tide-meslo.sh]] | Install tide v6 prompt + Meslo Nerd Font | (5) configs in place |

After subjects, run per-distro AI tool guides at `docs/reinstall-guides/{cachyos,debian}/`.

## System Scripts

| Script | Purpose |
|--------|---------|
| [[live-env-setup\|live-env-setup.sh]] | CachyOS live ISO post-install — clones dotfiles, adds drives, symlinks, bootstrap |
| [[REBUILD_SCRIPT\|REBUILD_SCRIPT.sh]] | Master 8-step rebuild — full system recovery from backup |
| [[healthcheck\|healthcheck.sh]] | System health check — GPUs, mounts, services |
| [[lxc-provision\|lxc-provision.sh]] | Proxmox host-side LXC creation — pct create, user, SSH keys, /srv, snapshot |
| [[lxc-bootstrap\|lxc-bootstrap.sh]] | In-container shell setup — fish/zsh/fonts/aliases (Debian LXC) |
| [[build-gold-lxc\|build-gold-lxc.sh]] | Proxmox host — builds gold LXC template (VMID 9000) for instant cloning |

## GPU & AI

| Script | Purpose |
|--------|---------|
| [[llama-server\|llama-server.sh]] | llama-server wrapper — sets CUDA_PATH, execs built binary |
| [[forge-start\|forge-start.sh]] | SD WebUI Forge Neo launcher |
| [[toggle-p40\|toggle-p40.sh]] | Toggle Tesla P40 GPU on/off |
| [[toggle-gpu-profile\|toggle-gpu-profile.sh]] | Switch GPU power profiles (compute / graphics) |

## Workspace & Config

| Script | Purpose |
|--------|---------|
| [[link-workspace\|link-workspace.sh]] | Create workspace symlinks (SSH, browser profiles, dotfiles) |
| [[bootstrap-configs\|bootstrap-configs.sh]] | Standalone config symlinker (like bootstrap.sh, extracted for subjects use) |
| [[check-fixes\|check-fixes.sh]] | Quality gate — tracks upstream KDE bugs, blocks updates within cooldown |
| [[test-cleanup-backups\|test-cleanup-backups.sh]] | Test/cleanup backup files |

## Configs

| File | Purpose |
|------|---------|
| [[fastfetch\|fastfetch.jsonc]] | Fastfetch system info display — color-coded tree-style, CachyOS logo, section groups |

## Notes

- All scripts are idempotent — safe to re-run.
- Edit the CONFIG block at the top of each script to match your system.
- Scripts assume a fresh OS install (no existing configs).

## Roadmap

- ~~[[projects/meta-scripts|Meta Script Project]]~~ — abandoned. Goals achieved ad-hoc by individual scripts (lxc-bootstrap flags, llama-loader IR/dialect separation).
