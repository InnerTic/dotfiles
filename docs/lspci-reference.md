# lspci Reference

Source: [lspci Command Cheat Sheet: All Flags & Examples](https://www.commandinline.com/lspci-command-cheat-sheet/) (Jan 2026)

## Overview

`lspci` lists every device on the PCI/PCIe buses with vendor, model, slot, and kernel-driver bindings. Indispensable for diagnosing driver problems, identifying GPUs/NICs, and inventorying hardware.

## Syntax

```
lspci [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-v` / `-vv` / `-vvv` | Verbosity (progressive detail) |
| `-k` | Show kernel driver + modules |
| `-nn` | Numeric vendor:device IDs + text names |
| `-n` | Numeric IDs only |
| `-t` | Tree view of bus topology |
| `-D` | Show full PCI domain |
| `-s SLOT` | Filter to slot (e.g. `00:1f.2`) |
| `-d [V]:[D]:[CC]` | Filter by vendor/device/class |
| `-m` / `-mm` | Machine-readable output |
| `-x` / `-xxx` | Hex dump of config space |
| `-i FILE` | Alternate PCI ID database |

## Best Combos & Why

### 1. `lspci -nnk` — The King

Shows numeric IDs + kernel driver + modules in one command. The article says it "answers more questions in one screen than minutes of `dmesg` trawling."

```
lspci -nnk | grep -A2 VGA
# 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA106 [GeForce RTX 3060 Lite Hash Rate] [10de:2504]
#         Kernel driver in use: nvidia
#         Kernel modules: nouveau, nvidia_drm, nvidia
```

**When to use:** First stop in any hardware investigation — driver missing? Wrong module? Unknown device? This tells you instantly.

### 2. `lspci -vv -s SLOT` — Deep Dive

Shows PCIe link speed/width (`LnkSta`/`LnkCap`), memory regions, all capabilities for one device. Cut-and-paste examples for this system (Akuma):

```
# RTX 3060 — GPU 0 (slot 01:00.0)
lspci -vv -s 01:00.0

# Tesla P40 — GPU 1, passed through to VM via vfio-pci (slot 04:00.0)
lspci -vv -s 04:00.0

# NVMe boot drive (slot 07:00.0)
lspci -vv -s 07:00.0

# Realtek 2.5GbE NIC (slot 06:00.0)
lspci -vv -s 06:00.0

# WiFi card (slot 05:00.0)
lspci -vv -s 05:00.0

# Check negotiated link width/speed on any device
lspci -vv -s 01:00.0 | grep -E "LnkSta|LnkCap"
lspci -vv -s 04:00.0 | grep -E "LnkSta|LnkCap"
```

**When to use:** A specific card is flaky or running below expected speed. Check negotiated link width vs. capability.

### 3. `lspci -tv` — Topology Tree

Shows which devices hang off which bridge.

```
lspci -tv
# -[0000:00]-+-00.0  AMD Renoir/Cezanne Root Complex
#            +-01.1-[01]--+-00.0  NVIDIA GA106 [RTX 3060]
#            |            \-00.1  NVIDIA HDMI Audio
#            +-02.1-[02-06]--+-00.0  AMD USB 3.1 XHCI
#            |               +-00.1  AMD SATA Controller
#            |               \-00.2-[03-06]--+-00.0-[04]----00.0  NVIDIA GP102 [Tesla P40]
#            |                               +-08.0-[05]----00.0  Realtek RTL8852BE WiFi
#            |                               \-09.0-[06]----00.0  Realtek RTL8125 2.5GbE
#            +-02.2-[07]----00.0  Crucial P5 Plus NVMe
#            +-08.1-[08]--+-00.1  AMD HDMI/DP Audio
#            |            +-00.3  AMD USB 3.1
#            |            \-00.6  AMD HD Audio
#            +-14.0  AMD FCH SMBus
#            +-14.3  AMD FCH LPC Bridge
#            \-18.3  AMD Cezanne Data Fabric
```

**When to use:** Multi-GPU or multi-NIC setups — see which devices share a bridge and might contend for bandwidth (important for dual-GPU AI work).

### 4. `lspci -d ::CLASS` — Class Filter

Filter by PCI class code. Common classes: `0300` (VGA/GPUs), `0302` (3D/Compute GPUs), `0200` (Ethernet), `0280` (WiFi), `0108` (NVMe).

```
# All GPUs (including compute-only)
lspci -d ::0300; lspci -d ::0302

# All NICs
lspci -d ::0200

# All NVIDIA devices
lspci -d 10de:

# Real-world on Akuma:
# $ lspci -d ::0300
# 01:00.0 VGA compatible controller: NVIDIA GA106 [GeForce RTX 3060]
# $ lspci -d ::0302
# 04:00.0 3D controller: NVIDIA GP102GL [Tesla P40]
# $ lspci -d ::0200
# 06:00.0 Ethernet controller: Realtek RTL8125 2.5GbE
# $ lspci -d ::0108
# 07:00.0 Non-Volatile memory controller: Crucial P5 Plus NVMe
```

**When to use:** Clean inventory of one device type without grepping noise.

### 5. `lspci -nnk | grep -E "Network|Ethernet|Wireless"` — NIC Audit

Quick network adapter inventory with IDs and drivers.

```
lspci -nnk | grep -E "Network|Ethernet|Wireless"
# 05:00.0 Network controller [0280]: Realtek RTL8852BE WiFi [10ec:b852]
#         Kernel driver in use: rtw89_8852be
# 06:00.0 Ethernet controller [0200]: Realtek RTL8125 2.5GbE [10ec:8125]
#         Kernel driver in use: r8169
```

**When to use:** Troubleshooting network driver issues or verifying NIC firmware.

## Usage Flow

1. **Inventory** → `lspci -nnk` (full listing with drivers)
2. **Filter** → `lspci -d ::0300; lspci -d ::0302` (all GPUs incl. compute) or `lspci -nnk | grep -i nvidia`
3. **Drill** → `lspci -vv -s 01:00.0` (full RTX 3060 details), `lspci -vv -s 04:00.0` (Tesla P40)
4. **Topology** → `lspci -tv` (understand bus layout — e.g. P40 is behind the chipset, not direct to CPU)

## Common Pitfalls

- **`lspci: command not found`** → install `pciutils`
- **Unknown device IDs** → `sudo update-pciids` refreshes the database
- **Permission warnings on `-vv`** → full config space requires root
- **Containers see host PCI** → trust the host view, not the container's

## Pro Tips

- Pipe to `grep -E "Network|Ethernet|Wireless"` for a quick NIC inventory
- Combine `lspci -nnk` with `modinfo` to confirm correct driver/module mapping
- For PCIe link speed and width: `lspci -vv -s SLOT | grep -E "LnkSta|LnkCap"`
- `setpci -s SLOT KEY=VAL` for poking config registers (rare, dangerous)
