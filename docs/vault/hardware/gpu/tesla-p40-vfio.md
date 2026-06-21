# Tesla P40 — VFIO Passthrough / GPU Isolation

## Problem

When the Tesla P40 is physically installed on the PCIe bus:

- Without power connected, the NVIDIA driver tries to enumerate it and can hang
- Even when working, the driver managing both GPUs can cause Steam/Proton instability
- Need to hand the P40 off so it doesn't interfere with gaming on the RTX 3060

## Hardware

| GPU | PCI ID | Bus |
|-----|--------|-----|
| RTX 3060 | `10de:2504` | `01:00.0` |
| Tesla P40 | `10de:1b38` | `04:00.0` |

## Quick Toggle Script

Use `scripts/toggle-p40.sh` to switch between modes:

```bash
./toggle-p40.sh              # show current state
./toggle-p40.sh default      # NVIDIA manages both (PCIe Gen3 fix)
./toggle-p40.sh dpm          # Dynamic Power Management
./toggle-p40.sh vfio         # VFIO passthrough (isolate for VM)
```

A convenience wrapper `scripts/toggle-gpu-profile.sh` detects the current mode and toggles to the opposite (Steam ↔ AI).

Both scripts require passwordless sudo. Configure with:
```bash
echo "ken ALL=(ALL) NOPASSWD: /home/ken/dotfiles/scripts/toggle-p40.sh" | sudo tee /etc/sudoers.d/toggle-p40
```

The script edits `KERNEL_CMDLINE[default]+="..."` in `/etc/default/limine` (the `limine-entry-tool` template, not `/boot/limine.conf` directly).

---

## Manual Steps (legacy — use the script instead)

### Option A — VFIO Passthrough (Full Isolation)

Binds the P40 to `vfio-pci` so the NVIDIA driver never touches it. Use this if you only use the P40 for CUDA workloads inside a VM.

Edit `/etc/default/limine` and add `vfio-pci.ids=10de:1b38` to the `KERNEL_CMDLINE` line, then:

```bash
sudo sed -i 's/^MODULES=()/MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_pci_core)/' /etc/mkinitcpio.conf
sudo mkinitcpio -P
sudo reboot
```

Verify: `lspci -nnk -d 10de:1b38` should show `Kernel driver in use: vfio-pci`.

### Option B — Dynamic Power Management

Keeps the P40 on the NVIDIA driver but forces dynamic power management to prevent hangs when the card isn't fully powered.

Edit `/etc/default/limine` and add `nvidia.NVreg_DynamicPowerManagement=0x02` to the `KERNEL_CMDLINE` line, then reboot.

### Reverting

Edit `/etc/default/limine` to remove the added parameter, and for VFIO also reset `MODULES=()` in `/etc/mkinitcpio.conf`, then regenerate initramfs and reboot.

---

## General Notes

- The live-env-setup.sh already adds `nvidia.NVreg_EnablePCIeGen3=1` for P40 PCIe compatibility. This should remain regardless of which option you choose.
- For VFIO mode, the P40 will not appear in `nvidia-smi` and cannot be used by CUDA on the host — only inside a VM with VFIO passthrough.
- See `docs/gpu/llama-setup.md` for BIOS requirements (Above 4G Decoding, CSM disabled) and the dual-GPU dual-arch CUDA build procedure.
- CachyOS uses Limine with snapshot-based boot entries. The template at `/etc/default/limine` feeds `limine-entry-tool`, which generates `/boot/limine.conf`. Always edit the template, not the generated file.

---

## Development Notes — Toggle Script Bugs Found During Testing

The toggle script went through several iterations of bugfixes discovered through real-world use:

### Bug 1: `set -euo pipefail` crash in `cleanup_backups`
- **Symptom:** Script silently exited after `sudo cp` (backup succeeded, then died).
- **Root cause:** `cleanup_backups` used `ls "$dir"/$pattern` which returns exit code 2 when no files match the glob. Combined with `pipefail`, the `ls | wc -l` pipeline failed, and `set -e` killed the script.
- **Fix:** Switched from `ls` + pipefail-unsafe pipeline to `find -name | wc -l` + `xargs -0 ls -t` for counting and sorting.

### Bug 2: Limine hook prompt hung mkinitcpio
- **Symptom:** `mkinitcpio -P` prompted "Rebuild limine entries? [y/N]" and waited indefinitely.
- **Root cause:** The `limine-entry-tool` hook detects changes to `/etc/default/limine` and asks for confirmation.
- **Fix:** Piped `yes | sudo mkinitcpio -P` inside a `(set +o pipefail; ...)` subshell to auto-answer without propagating SIGPIPE.

### Bug 3: Backup cleanup never actually pruned
- **Symptom:** Backups accumulated past the `keep=3` limit.
- **Root cause:** `while IFS= read -r -d '' old` with `IFS=` (empty) disabled word splitting, so `$old` captured the entire `TIMESTAMP PATH` string. `rm -f "$old"` silently failed — no file exists with a timestamp prefix.
- **Fix:** Changed to `while read -r -d '' _ old` using default IFS so the timestamp goes into `_` (discarded) and the path into `old`. Also moved the `while read` into a process substitution `<(...)` to avoid pipefail interference.

### Bug 4: No visibility into stalled commands
- **Symptom:** User saw `Backing up...` then nothing — no way to tell what command was hanging.
- **Fix:** Added `set -x` / `{ set +x; } 2>/dev/null` wrapping around all mutation commands so each command prints with `+` prefix as it executes.

### Lesson
Real-world beta testing caught every one of these bugs. The script was functionally correct on paper, but edge cases (empty directories, interactive prompts, IFS behavior, pipefail semantics) only surfaced when actually running it against the live system.
