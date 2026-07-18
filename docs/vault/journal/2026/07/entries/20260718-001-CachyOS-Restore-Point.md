---
type: work-entry
id: 20260718-001
status: completed
confidence: high
time_spent: 4h
projects:
  - "[[CachyOS Restore]]"
daily:
  - "[[2026-07-18]]"
systems:
  - "[[LibreWolf]]"
  - "[[fstab]]"
  - "[[keyd]]"
  - "[[G502 Hero]]"
scripts:
  - /home/ken/dotfiles/librewolf/policies.json
  - /etc/pacman.d/hooks/librewolf-policies.hook
  - /home/ken/.librewolf/librewolf.overrides.cfg
files:
  - /etc/fstab
  - /home/ken/.librewolf/coy0vc1u.ken/compatibility.ini
  - /home/ken/.librewolf/librewolf.overrides.cfg
  - /home/ken/dotfiles/librewolf/policies.json
  - /etc/pacman.d/hooks/librewolf-policies.hook
  - /home/ken/dotfiles/docs/vault/software/librewolf.md
  - /home/ken/dotfiles/docs/vault/software/g502-hero-setup.md
  - /home/ken/dotfiles/docs/vault/software/coolercontrol.md
  - /home/ken/dotfiles/docs/vault/reference/keyd-stack.md
  - /home/ken/dotfiles/docs/vault/software/gaming/gw2-multibox-wine-setup.md
  - /home/ken/dotfiles/docs/vault/system/drives-and-mounts.md
  - /home/ken/dotfiles/docs/vault/changelog.md
  - /home/ken/dotfiles/docs/vault/QUICK-START.md
created_pages:
  - "[[software/g502-hero-setup]]"
  - "[[software/coolercontrol]]"
  - "[[software/librewolf]]"
  - "[[2026-07-18]]"
  - "[[20260718-001-CachyOS-Restore-Point]]"
updated_pages:
  - "[[changelog]]"
  - "[[reference/keyd-stack]]"
  - "[[software/gaming/gw2-multibox-wine-setup]]"
  - "[[system/drives-and-mounts]]"
  - "[[QUICK-START]]"
tags:
  - cachyos
  - restore
  - librewolf
  - fstab
  - g502
  - cleanup
  - maintenance
modified: 2026-07-18
---

# 20260718-001 — CachyOS Restore Point

Date: 2026-07-18

## Goal

Bring this month-old CachyOS install up to vault standards so it can serve as a clean re-imaging restore point. Audit what's documented vs what's actually on the system, fix discrepancies, and document everything so the work isn't lost on next reinstall.

## What Was Done

### LibreWolf setup
- **Profile version mismatch**: Profile was created by 152.0.6 (AUR) but CachyOS repos have 151.0.4. Fixed `compatibility.ini`.
- **Overrides file**: Created `~/.librewolf/librewolf.overrides.cfg` with settings captured from the existing `ken` profile — RFP off (uses `fingerprintingProtection`), Firefox Sync on, DuckDuckGo default, tracking protection on, autoscroll, dark theme, etc.
- **Custom search engine**: Added local SearXNG instance (`http://172.16.12.16:8888`) to LibreWolf's `policies.json` at `/usr/lib/librewolf/distribution/`.
- **Pacman hook**: Created `/etc/pacman.d/hooks/librewolf-policies.hook` to redeploy the custom policies.json after every `librewolf-bin` update.

### Fstab corrections
- **sdc1 HDD-Data**: UUID was pointing at old ntfs partition — corrected to current btrfs UUID `f0b1d710...`.
- **sde4 vm-storage**: UUID was stale — corrected to `58f7f216...`. Later removed entirely since sde is a USB-connected drive and shouldn't be in fstab.
- **Removed USB/EFI entries**: sde (USB ADATA SSD), sdf (other OS), and all EFI partitions removed from fstab.
- **Added nofail**: `/boot` and `/home` now have `nofail` to prevent boot hangs if those drives are missing.
- **Verified**: All mounts active, `mount -a` succeeds.

### Cache cleanup
- **Shelly cache**: Removed `~/.cache/Shelly/` — 20G of stale AI agent cache.
- **Paru clones**: Removed `~/.cache/paru/clone/` — AUR source clones no longer needed.
- **Pip cache**: `pip cache purge` — 2.7G freed.
- **Go build**: `go clean -cache` — 1.3G freed.
- **Orphans**: Removed `cccl` package.
- **Result**: `~/.cache/` went from ~30G to 1.8G (remaining is active nvidia shaders, uv, electron, wine, librewolf cache).

### Package installs
Installed: `go`, `zip`, `tmux`, `python-virtualenv`, `python-pip`, `meson`, `ninja`, `check`, `swig`.

### G502 Hero mouse
- **libratbag/piper**: Installed from repos.
- **Button mapping**: Remapped rear thumb (back) to X11 button 4, front thumb to KEY_C, sniper to KEY_V, scroll tilt to 2/N.
- **Known bug**: libratbag #1853 — G502 HERO retains stale modifier keys when remapping. Button 4 had `Ctrl+Alt+C` previously; setting to plain `KEY_C` still emitted Alt. Fixed by building libratbag from git with PR #1843 (merged Jul 10, 2026).
- **Vault doc**: Created `software/g502-hero-setup.md` with full button map table, build instructions, and bug reference.

### Vault documentation
- **Changelog**: Added 2026-07-18 entry covering all changes.
- **Drives-and-mounts**: Updated UUIDs, mount points, drive selection guide for CachyOS.
- **QUICK-START**: Added troubleshooting links for keyd, LibreWolf, and G502.
- **keyd-stack**: Documented known issue — keyd breaks keyboard input in Wine/Steam/GW2.
- **CoolerControl**: Created vault doc.
- **Journal**: Created daily note and this work entry matching the vault journal format (template-driven, cross-linked).

### Vault audit
Compared this CachyOS install against vault docs. Key drifts found:
- Scripts at `~/infra/` not `~/.openclaw/workspace/scripts/` as vault says
- Git user is Ken Isley, not InnerTic
- Drive letters differ from MX Linux docs (known drift)
- tmux was not installed (now fixed)
- 40+ documented packages not installed (most optional)

## Decisions

**LibreWolf RFP off**: User's existing profile had `privacy.resistFingerprinting` disabled and `privacy.fingerprintingProtection` enabled instead. Honored that choice in the overrides rather than reverting to LibreWolf defaults.

**USB drives not in fstab**: sde (ADATA SSD in USB enclosure) has a flaky USB connection causing constant re-enumeration. Keeping it out of fstab avoids system hangs — let udisks2 handle it.

**Patched libratbag from git**: The stale modifier bug (Alt retained from previous Ctrl+Alt+C mapping) is a G502 HERO firmware interaction issue. PR #1843 was merged 8 days ago, not in the packaged 0.18-1. Built from source to fix it.

## Build Commands

```bash
git clone https://github.com/libratbag/libratbag.git /tmp/libratbag
cd /tmp/libratbag
meson setup builddir --prefix=/usr
ninja -C builddir
sudo ninja -C builddir install
sudo systemctl kill -s TERM ratbagd
```

## Issues Encountered

| Problem | Fix |
|---------|-----|
| LibreWolf profile version mismatch | Downgraded `LastVersion` in `compatibility.ini` |
| HDD-Data UUID wrong in fstab | Old ntfs UUID, disk was reformatted to btrfs |
| USB drive constant re-enumeration | Removed from fstab, let udisks2 auto-mount |
| G502 button C retained Alt modifier | Patched libratbag from git (PR #1843) |
| pacman mirrors returning 404 | Database refresh (`pacman -Syy`) resolved it |

## References

- [[software/librewolf]]
- [[software/g502-hero-setup]]
- [[software/coolercontrol]]
- [[reference/keyd-stack]]
- [[system/drives-and-mounts]]
- [[changelog]]
- https://github.com/libratbag/libratbag/issues/1853
- https://www.librewolf.net/docs/settings/
