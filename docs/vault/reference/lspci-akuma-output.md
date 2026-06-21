# lspci — Akuma System Output

Host: **Akuma** (CachyOS/Arch, AMD Ryzen Cezanne, dual GPU)
Generated: 2026-06-14

`pull the relevent info out for obsidian://open?vault=docs&file=context%2Fsystem-profile and update that file using this as well as updating seytem-profile doc`
---

## Full Inventory — `lspci`

```
00:00.0 Host bridge: AMD Renoir/Cezanne Root Complex
00:00.2 IOMMU: AMD Renoir/Cezanne IOMMU
00:01.0 Host bridge: AMD Renoir PCIe Dummy Host Bridge
00:01.1 PCI bridge: AMD Renoir PCIe GPP Bridge
00:02.0 Host bridge: AMD Renoir PCIe Dummy Host Bridge
00:02.1 PCI bridge: AMD Renoir/Cezanne PCIe GPP Bridge
00:02.2 PCI bridge: AMD Renoir/Cezanne PCIe GPP Bridge
00:08.0 Host bridge: AMD Renoir PCIe Dummy Host Bridge
00:08.1 PCI bridge: AMD Renoir Internal PCIe GPP Bridge to Bus
00:14.0 SMBus: AMD FCH SMBus Controller (rev 51)
00:14.3 ISA bridge: AMD FCH LPC Bridge (rev 51)
00:18.0-18.7 Host bridge: AMD Cezanne Data Fabric (x8 functions)
01:00.0 VGA compatible: NVIDIA GA106 [GeForce RTX 3060 Lite Hash Rate] (rev a1)
01:00.1 Audio: NVIDIA GA106 High Definition Audio (rev a1)
02:00.0 USB: AMD 500 Series Chipset USB 3.1 XHCI
02:00.1 SATA: AMD 500 Series Chipset SATA Controller
02:00.2 PCI bridge: AMD 500 Series Switch Upstream Port
03:00.0 PCI bridge: AMD 500 Series Switch Downstream Port
03:08.0 PCI bridge: AMD 500 Series Switch Downstream Port
03:09.0 PCI bridge: AMD 500 Series Switch Downstream Port
04:00.0 3D controller: NVIDIA GP102GL [Tesla P40] (rev a1)
05:00.0 Network: Realtek RTL8852BE 802.11ax WiFi
06:00.0 Ethernet: Realtek RTL8125 2.5GbE (rev 05)
07:00.0 NVMe: Micron/Crucial P5 Plus NVMe SSD
08:00.0 Non-Essential Instrumentation: AMD Zeppelin/Raven dummy
08:00.1 Audio: AMD/ATI Renoir/Cezanne HDMI/DP Audio
08:00.2 Encryption: AMD Raven/Renoir Platform Security Processor
08:00.3 USB: AMD Renoir/Cezanne USB 3.1
08:00.4 USB: AMD Renoir/Cezanne USB 3.1
08:00.6 Audio: AMD Ryzen HD Audio
```

---

## With Drivers & IDs — `lspci -nnk`

```
01:00.0 VGA compatible [0300]: NVIDIA GA106 [RTX 3060 LHR] [10de:2504]
        Subsystem: EVGA Corp [3842:3656]
        Kernel driver in use: nvidia
        Kernel modules: nouveau, nvidia_drm, nvidia

04:00.0 3D controller [0302]: NVIDIA GP102GL [Tesla P40] [10de:1b38]
        Subsystem: NVIDIA Corp [10de:11d9]
        Kernel driver in use: vfio-pci
        Kernel modules: nouveau, nvidia_drm, nvidia

05:00.0 Network controller [0280]: Realtek RTL8852BE [10ec:b852]
        Subsystem: AzureWave [1a3b:5471]
        Kernel driver in use: rtw89_8852be
        Kernel modules: rtw89_8852be

06:00.0 Ethernet [0200]: Realtek RTL8125 2.5GbE [10ec:8125] (rev 05)
        Subsystem: ASUS [1043:87d7]
        Kernel driver in use: r8169
        Kernel modules: r8169

07:00.0 Non-Volatile memory [0108]: Crucial P5 Plus NVMe [c0a9:5407]
        Subsystem: Crucial [c0a9:0100]
        Kernel driver in use: nvme
        Kernel modules: nvme
```

---

## Topology Tree — `lspci -tv`

```
-[0000:00]-+-00.0  AMD Renoir/Cezanne Root Complex
           +-00.2  AMD Renoir/Cezanne IOMMU
           +-01.0  AMD Renoir PCIe Dummy Host Bridge
           +-01.1-[01]--+-00.0  NVIDIA GA106 [RTX 3060]         ← GPU 0 (direct to CPU)
           |            \-00.1  NVIDIA HDMI Audio
           +-02.0  AMD Renoir PCIe Dummy Host Bridge
           +-02.1-[02-06]--+-00.0  AMD USB 3.1 XHCI
           |               +-00.1  AMD SATA Controller
           |               \-00.2-[03-06]--+-00.0-[04]----00.0  NVIDIA GP102 [Tesla P40]  ← GPU 1 (via chipset)
           |                               +-08.0-[05]----00.0  Realtek RTL8852BE WiFi
           |                               \-09.0-[06]----00.0  Realtek RTL8125 2.5GbE
           +-02.2-[07]----00.0  Crucial P5 Plus NVMe            ← boot drive (direct to CPU)
           +-08.0  AMD Renoir PCIe Dummy Host Bridge
           +-08.1-[08]--+-00.0  AMD Zeppelin dummy
           |            +-00.1  AMD HDMI/DP Audio
           |            +-00.2  AMD Platform Security Processor
           |            +-00.3  AMD USB 3.1
           |            +-00.4  AMD USB 3.1
           |            \-00.6  AMD Ryzen HD Audio
           +-14.0  AMD FCH SMBus
           +-14.3  AMD FCH LPC Bridge
           +-18.0 through 18.7  AMD Cezanne Data Fabric
```

---

### Lane-by-Lane Breakdown

**`01.1-[01]` — RTX 3060 (CPU-direct GPU)**
```
01.1-[01]--+-00.0  RTX 3060
           \-00.1  HDMI Audio
```
This is the primary x16 slot wired directly to the CPU. The 3060 has the whole lane to itself (plus its audio function sharing the same physical slot). Best possible latency — use this GPU for LLM inference.

**`02.1-[02-06]` — Chipset umbrella (everything else)**
```
02.1-[02-06]--+-00.0  USB 3.1 XHCI
              +-00.1  SATA Controller
              \-00.2-[03-06]--+-00.0-[04]----00.0  Tesla P40
                              +-08.0-[05]----00.0  WiFi
                              \-09.0-[06]----00.0  2.5GbE NIC
```
All of these share a single PCIe link (x4 Gen3 = ~4 GB/s) from the CPU to the chipset, and then fight for bandwidth inside the chipset's switch fabric:

- **`03.00.0-[04]`** → Tesla P40 (also technically x16, but upstream bottlenecked to chipset link)
- **`03.08.0-[05]`** → WiFi card (x1)
- **`03.09.0-[06]`** → 2.5GbE NIC (x1)
- USB 3.1 and SATA also hang off the same chipset link.

**`02.2-[07]` — NVMe (CPU-direct)**
```
02.2-[07]----00.0  Crucial P5 Plus NVMe
```
Secondary CPU-attached x4 lane, separate from the GPU and chipset. No contention.

**`08.1-[08]` — AMD internal fabric**
```
08.1-[08]--+-00.0  dummy
           +-00.1  HDMI/DP Audio (iGPU)
           +-00.2  PSP (encryption)
           +-00.3  USB 3.1
           +-00.4  USB 3.1
           \-00.6  HD Audio
```
Onboard peripherals — integrated GPU audio, PSP, USB, and HD audio. These are on the internal AMD bus, not PCIe slots.

### What This Means in Practice

| Traffic | Path | Contention |
|---------|------|------------|
| LLM inference (3060) | CPU ↔ x16 direct | None — dedicated lane |
| VM GPU (P40) | P40 ↔ chipset ↔ CPU x4 | Shares with USB, SATA, WiFi, NIC |
| NVMe reads/writes | SSD ↔ CPU x4 direct | None — separate lane |
| Network bulk transfer | NIC ↔ chipset ↔ CPU x4 | Competes with P40, USB, SATA |
| USB 3.1 heavy I/O | USB ↔ chipset ↔ CPU x4 | Competes with P40 and NIC |

**Bottom line:** The P40 being behind the chipset and sharing `02.1`'s x4 upstream link with SATA, USB, WiFi, and the 2.5GbE NIC means heavy network transfers or disk I/O via chipset SATA could steal bandwidth from the P40. If you're doing GPU compute on the P40 inside a VM while also hammering the NIC, you might see throughput drops on both. The RTX 3060 on its own CPU-direct lane has no such contention.

---

## Class Filters

### GPUs
```
$ lspci -d ::0300
01:00.0 VGA compatible: NVIDIA GA106 [GeForce RTX 3060]

$ lspci -d ::0302
04:00.0 3D controller: NVIDIA GP102GL [Tesla P40]

$ lspci -d 10de:   # All NVIDIA devices
01:00.0 VGA compatible: NVIDIA GA106 [RTX 3060]
01:00.1 Audio: NVIDIA GA106 HDMI Audio
04:00.0 3D controller: NVIDIA GP102GL [Tesla P40]
```

### Networking
```
$ lspci -d ::0200
06:00.0 Ethernet: Realtek RTL8125 2.5GbE

$ lspci -d ::0280
05:00.0 Network: Realtek RTL8852BE 802.11ax WiFi
```

### Storage
```
$ lspci -d ::0108
07:00.0 NVMe: Crucial P5 Plus NVMe SSD
```

---

## Deep Dive — `lspci -vv -s SLOT`

### RTX 3060 (`01:00.0`)
```
01:00.0 VGA compatible: NVIDIA GA106 [RTX 3060 LHR] (rev a1)
        Subsystem: EVGA Corp Device 3656
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
        Interrupts: pin B disabled, MSI(X) routed to IRQ 82
        IOMMU group: 9
        Region 0: fb000000 (32-bit, non-prefetchable) [16M]
        Region 1: 7400000000 (64-bit, prefetchable) [16G]
        Region 3: 7800000000 (64-bit, prefetchable) [32M]
        Region 5: I/O at f000 [128]
        Expansion ROM at fc000000 [disabled] [512K]
        Kernel driver in use: nvidia
```

### Tesla P40 (`04:00.0`)
```
04:00.0 3D controller: NVIDIA GP102GL [Tesla P40] (rev a1)
        Subsystem: NVIDIA Corp Device 11d9
        Control: I/O- Mem- BusMaster- SpecCycle-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
        Interrupts: pin B routed to IRQ 255
        IOMMU group: 10
        Region 0: f9000000 (32-bit, non-prefetchable) [disabled] [16M]
        Region 1: 6800000000 (64-bit, prefetchable) [disabled] [32G]
        Region 3: 7000000000 (64-bit, prefetchable) [disabled] [32M]
        Kernel driver in use: vfio-pci              ← passed through to VM
```

### Crucial P5 Plus NVMe (`07:00.0`)
```
07:00.0 Non-Volatile memory: Crucial P5 Plus NVMe SSD (prog-if 02 [NVM Express])
        Subsystem: Crucial Device 0100
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
        Interrupts: pin B disabled, MSI(X) routed to IRQ 65-81
        IOMMU group: 11
        Region 0: fc600000 (64-bit, non-prefetchable) [16K]
        Kernel driver in use: nvme
```

---

## Device Summary

| Slot | Device | Driver | Purpose |
|------|--------|--------|---------|
| `01:00.0` | RTX 3060 (GA106) | `nvidia` | GPU 0 — LLM inference, rendering |
| `01:00.1` | GA106 HDMI Audio | `snd_hda_intel` | Audio via GPU |
| `04:00.0` | Tesla P40 (GP102) | `vfio-pci` | GPU 1 — passed to VM |
| `05:00.0` | Realtek RTL8852BE | `rtw89_8852be` | WiFi |
| `06:00.0` | Realtek RTL8125 | `r8169` | 2.5GbE Ethernet |
| `07:00.0` | Crucial P5 Plus NVMe | `nvme` | Boot drive |
| `08:00.3/4` | AMD USB 3.1 | `xhci_hcd` | USB ports |
