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

| Issue | Go To |
|-------|-------|
| Symlinks wrong | [[getting-started/workspace-symlink]] |
| GPU not detected | [[system/gpu-config]] |
| SSH keys missing | [[system/storage-layout]] + verify workspace mounted |
| llama.cpp won't run | [[software/ai-tools/llama-setup]] |
| Wine/Proton issues | [[software/gaming/gw2-wine]] |
| Unknown error | [[reference/troubleshooting]] |

Full docs at [[index]].
