# Changelog

All notable changes to this dotfiles repo.

## 2026-06-06

- opencode: add OpenRouter + OpenCode Zen provider API keys to global config
- docs: rewrite llama-setup.md — CUDA 12.4 is now the primary path (was 13.3); removed pacman cuda, system CUDA gotchas; dual-arch build is the default
- rebuild: add step 4b — install Oh My Zsh, powerlevel10k, zsh-syntax-highlighting, zsh-autosuggestions
- rebuild: add NVIDIA driver conflict warning in prerequisites — P40 must be physically removed before OS install
- rebuild: replace stale m2_storage fstab entry with VM-Disks (sde1, xfs, new UUID)
- rebuild: remove `cuda` from pacman at step 1 (4.8GB, conflicts with local CUDA 12.4 dual-arch setup); add note about CUDA 12.9 from paru for Pascal
- rebuild: strip comments from pkglist-apps.txt before piping to pacman
- rebuild: guard fstab append with idempotency check (prevent duplicate entries)
- rebuild: `rm -rf` symlink targets before `ln -sf` (fix permission-denied on re-run)
- add: CHANGELOG.md
- docs: update sde → VM-Disks mount point, add thorium-shell --force-dark-mode patch note
- CUDA 12.4 dual-arch build: sm_61 + sm_86 for dual GPU
- docs: update P40 fix — kernel cmdline (not modprobe.d), power cable troubleshooting
- add: docs + rebuild script + live-env-setup + pkglist-apps.txt

## 2026-06-15

- disk: split sde 50/50 — sde1 ext4 (future OS, Limine), sde2 xfs (VMs at /mnt/vm-disks)
- docs: update UUIDs and drive layout across all docs for new sde partitioning

## Earlier

- GW2 multi-box Wine setup docs, cleanups, and formatting fixes
- AI context docs: system memory, profiles, layouts, fixbot references
- Storage layout setup, shell history dedup, rebuild notes
- Commands/quick-commands doc + `q` search function
- Clean up .zshrc, forge path fix, dynamic model loader
- Distro-agnostic bootstrap.sh
- Initial config dump
