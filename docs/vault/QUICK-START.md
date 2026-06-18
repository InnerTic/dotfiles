---
tags: [emergency, recovery, quickstart]
aliases: [emergency, quick-start, recovery, crisis]
updated: 2026-06-15
---

# 🚨 Emergency Recovery — 5 Minute Start

**Your system died. You need it working NOW.**

## Step 1: Fresh OS Install
```bash
# Boot into live USB, install base OS
# Don't worry about config — we persist everything on workspace
```

## Step 2: Mount Workspace
```bash
sudo mount /mnt/workspace
# (or restore from backup if needed)
```

## Step 3: Restore Everything
```bash
# Clone dotfiles
git clone git@github.com:InnerTic/dotfiles.git /mnt/workspace/dotfiles

# Apply symlinks (merges workspace → home)
/mnt/workspace/dotfiles/scripts/link-workspace.sh --apply

# Run bootstrap (creates shell config, git config, etc.)
/mnt/workspace/dotfiles/bootstrap.sh

# Verify
/mnt/workspace/dotfiles/scripts/link-workspace.sh --status
```

## Step 4: Verify Key Systems
```bash
nvidia-smi              # GPU works?
ssh -T git@github.com   # SSH keys loaded?
ls ~/.ssh               # Should be symlink to workspace
```

**Done.** Everything else regenerates on first use (apps, caches, config).

---

## If Something Breaks

| Issue               | Go To                                                   |
| ------------------- | ------------------------------------------------------- |
| Symlinks wrong      | [[reference/workspace-symlink-strategy]]                          |
| GPU not detected    | [[gpu/gpu-config-notes]]                                    |
| SSH keys missing    | [[system/drives-and-mounts]] + verify workspace mounted |
| llama.cpp won't run | [[gpu/llama-setup]]                                         |
| Wine/Proton issues  | [[gaming/gw2-multibox-wine-setup]]                             |
| Boot entry broken   | [[system/dual-boot-recovery]]                                 |
| Keyboard not reaching game | [[system_backup/cachyos-steam-nvidia-input-log]] (check libinput) |

Full docs at [[INDEX]].
