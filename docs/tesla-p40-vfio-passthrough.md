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

## Option A — VFIO Passthrough (Full Isolation)

Binds the P40 to `vfio-pci` so the NVIDIA driver never touches it. Use this if you only use the P40 for CUDA workloads inside a VM.

### Step 1: Add P40 to VFIO IDs

```bash
sudo sed -i 's|root=UUID=[^ ]*|& vfio-pci.ids=10de:1b38|' /boot/limine.conf
```

Or manually add `vfio-pci.ids=10de:1b38` to the kernel cmdline line in `/boot/limine.conf`.

### Step 2: Add vfio_pci to mkinitcpio modules

```bash
sudo sed -i 's/^MODULES=()/MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_pci_core)/' /etc/mkinitcpio.conf
```

### Step 3: Regenerate initramfs

```bash
sudo mkinitcpio -P
```

### Step 4: Reboot

```bash
reboot
```

### Verify

```bash
lspci -nnk -d 10de:1b38
```

Should show `Kernel driver in use: vfio-pci` instead of `nvidia`.

---

## Option B — Dynamic Power Management (Keep on NVIDIA)

Keeps the P40 on the NVIDIA driver but forces dynamic power management to prevent hangs when the card isn't fully powered.

### Step 1: Add kernel parameter

```bash
sudo sed -i 's|root=UUID=[^ ]*|& nvidia.NVreg_DynamicPowerManagement=0x02|' /boot/limine.conf
```

### Step 2: Reboot

```bash
reboot
```

### Verify

```bash
nvidia-smi -q -d POWER | grep -A2 "GPU Power"
```

---

## Reverting

To undo either option, remove the added kernel parameter from `/boot/limine.conf` and (for Option A) revert `MODULES` in `/etc/mkinitcpio.conf`, then regenerate initramfs and reboot.

## Notes

- The live-env-setup.sh already adds `nvidia.NVreg_EnablePCIeGen3=1` for P40 PCIe compatibility. This should remain regardless of which option you choose.
- For Option A, the P40 will not appear in `nvidia-smi` and cannot be used by CUDA on the host — only inside a VM with VFIO passthrough.
- See `docs/llama-setup.md` for BIOS requirements (Above 4G Decoding, CSM disabled) and the dual-GPU dual-arch CUDA build procedure.
