# OpenWrt VM with WiFi Passthrough on Proxmox — Build Guide

Status: **live** — VM 100 (OpenWrt) is running on `pve` (172.16.7.1) with internet access.

## Hardware

| Component | Detail |
|---|---|
| Host | CachyOS (Proxmox VE on bare-metal), Intel Celeron/Pentium N-series |
| Kernel | 6.17.13-3-pve |
| WiFi card | Intel AX210 `[8086:2725]`, PCI `01:00.0` |
| IOMMU Group 5 | `00:13.0` (PCIe bridge) + `01:00.0` (WiFi) |
| Router | OPNsense 25 at `172.16.1.1`, MAC filtering enabled |
| Storage | 5400 RPM HDD — expect slow boots |

## VM Summary

| Field | Value |
|---|---|
| VM ID | 100 |
| Name | OpenWrt |
| BIOS | SeaBIOS (not OVMF — image is BIOS boot) |
| Machine | pc (not q35) |
| CPU | host, 2 cores |
| RAM | 512 MB |
| Disk | virtio0, 5 GB on local-lvm |
| NIC | e1000 on vmbr0 (not virtio — had zero-packet issue) |
| WiFi passthrough | `hostpci0: 01:00.0` (no `pcie=1`) |
| IP | 172.16.12.10/16 |
| Gateway | 172.16.7.1 (Proxmox host, via NAT) |

## Prerequisites

### 1. Enable IOMMU

Edit `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_aspm=off"
```

Then:

```bash
update-grub
update-initramfs -u -k all
reboot
```

Verify:

```bash
dmesg | grep -i "DMAR: IOMMU enabled"
```

### 2. Bind WiFi card to vfio-pci

Create `/etc/modprobe.d/vfio.conf`:

```
options vfio-pci ids=8086:2725 disable_idle_d3=1
softdep iwlwifi pre: vfio-pci
softdep iwlmvm pre: vfio-pci
```

Add to `/etc/modules-load.d/vfio.conf`:

```
vfio
vfio_iommu_type1
vfio_pci
```

Rebuild and reboot:

```bash
update-initramfs -u -k all
reboot
```

Verify:

```bash
lspci -nnv -s 01:00.0 | grep "Kernel driver"
# Must show: Kernel driver in use: vfio-pci
```

### 3. Confirm IOMMU isolation

```bash
bash -c 'for g in /sys/kernel/iommu_groups/*; do echo "IOMMU Group ${g##*/}:"; for d in $g/devices/*; do echo -e "\t$(lspci -nns ${d##*/})"; done; done'
```

The AX210 must be in its own group (or only with its PCIe bridge). If it shares with other devices, add `pcie_acs_override=downstream` to GRUB (⚠️ breaks isolation — VM can read host memory).

## The AX210 Reset Problem

The AX210 does **not** support FLR (function-level reset) or bus reset. Attempting either causes the card to go into D3cold and QEMU hangs for 65 seconds before crashing with:

```
vfio-pci 0000:01:00.0: not ready 65535ms after FLR; giving up
kvm: ../hw/pci/pci.c:1815: pci_irq_handler: Assertion `0 <= irq_num && irq_num < PCI_NUM_PINS' failed.
```

**Why `pcie_aspm=off`**: Without it, the card boots in D3cold and can never be brought out. With it, the card boots in D0 but still can't be reset. So we also need the hookscript.

**Solution — Hookscript** to disable reset methods before VM start.

Create `/var/lib/vz/snippets/wifi-reset-hook.sh`:

```bash
#!/bin/bash
set -e
vmId="$1"
runPhase="$2"
case "$runPhase" in
    pre-start)
        echo > /sys/bus/pci/devices/0000:01:00.0/reset_method 2>/dev/null
    ;;
esac
```

```bash
chmod +x /var/lib/vz/snippets/wifi-reset-hook.sh
```

Attach to the VM: `qm set 100 --hookscript local:snippets/wifi-reset-hook.sh`

**Why `disable_idle_d3=1`**: Prevents the vfio-pci driver from putting the card in low-power state when idle.

**Why `pcie=1` is NOT used**: The `pcie=1` flag on hostpci0 causes a QEMU PCI IRQ assertion crash with the AX210. The `pc` machine type with plain `hostpci0: 01:00.0` works.

**Why e1000 not virtio**: Virtio-net NICs had a zero-packet issue — interfaces appeared UP but no frames left the VM. Switching to e1000 fixed it. OpenWrt 25.12 includes the `e1000` driver built-in.

## Building the OpenWrt Image

Uses the OpenWrt 25.12.0 Image Builder with WiFi drivers and LuCI pre-installed.

```bash
cd /tmp
wget https://downloads.openwrt.org/releases/25.12.0/targets/x86/64/openwrt-imagebuilder-25.12.0-x86-64.Linux-x86_64.tar.zst
tar --zstd -xf openwrt-imagebuilder-25.12.0-x86-64.Linux-x86_64.tar.zst
cd openwrt-imagebuilder-25.12.0-x86-64.Linux-x86_64

make image PROFILE=generic PACKAGES="\
kmod-iwlwifi iwlwifi-firmware-ax210 kmod-mac80211 kmod-cfg80211 \
wpad luci luci-ssl \
kmod-ipt-offload iptables-nft \
dnsmasq-full tcpdump iperf3 usbutils ethtool \
kmod-usb-ohci kmod-usb-storage kmod-fs-ext4 kmod-fs-vfat \
block-mount curl wget-ssl nano openssh-sftp-server ca-certificates"
```

Output: `bin/targets/x86/64/openwrt-25.12.0-x86-64-generic-ext4-combined.img`

Copy to Proxmox, resize, import:

```bash
scp openwrt-25.12.0-x86-64-generic-ext4-combined.img root@pve:/root/openwrt.img
ssh root@pve
qemu-img resize /root/openwrt.img 5G
qm importdisk 100 /root/openwrt.img local-lvm
```

**Why 25.12.0 stable, not 25.12.5 snapshot**: Kernel modules (`kmod-*`) are version-locked to the kernel they were built for. The snapshot 25.12.5 had kernel 6.12.94 but the snapshots repository had moved to 6.18.x, making matching kmods unavailable. The stable 25.12.0 release has kernel 6.12.71 with matching kmods.

## VM Creation Commands

```bash
qm create 100 \
  --name OpenWrt \
  --memory 512 \
  --cores 2 \
  --cpu cputype=host \
  --machine pc \
  --bios seabios \
  --net0 e1000,bridge=vmbr0 \
  --scsihw virtio-scsi-pci \
  --numa 1 \
  --ostype l26 \
  --onboot 1 \
  --serial0 socket \
  --vga serial0

qm importdisk 100 /root/openwrt.img local-lvm
qm set 100 --virtio0 local-lvm:vm-100-disk-0
qm set 100 --boot order=virtio0
qm set 100 --hostpci0 01:00.0
qm set 100 --hookscript local:snippets/wifi-reset-hook.sh
```

## VM Network Config

OpenWrt `/etc/config/network`:

```
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        list ipaddr '127.0.0.1/8'

config globals 'globals'
        option ula_prefix 'fdfc:823a:5f42::/48'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        list ipaddr '172.16.12.10/16'
        option gateway '172.16.7.1'
        list dns '172.16.12.1'
        option ip6assign '60'
```

**Why gateway is 172.16.7.1 not 172.16.1.1**: The OPNsense router at 172.16.1.1 filters by MAC. It accepts traffic from the Proxmox host (`7a:1f:e0:2d:de:65`) but rejects the VM's e1000 MAC (`bc:24:11:b1:bc:c2`). Traffic is NAT'd through the Proxmox host.

## Proxmox Host NAT for VM

The OPNsense router blocks non-host MACs. Workaround: NAT the VM's traffic through the Proxmox host.

```bash
# Enable forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# NAT only the VM's traffic (NOT all 172.16.0.0/16 — breaks host internet)
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o enp2s0 -j MASQUERADE

# Allow forwarding (CRITICAL - without these, traffic is dropped)
iptables -A FORWARD -s 172.16.0.0/16 -j ACCEPT
iptables -A FORWARD -d 172.16.0.0/16 -j ACCEPT
```

**Critical**: Use `-o enp2s0` (physical interface) not `-o vmbr0` (bridge). The entire 172.16.0.0/16 subnet is NAT'd to support both the VM and WiFi clients connecting through it.

**Persistence**: Create a systemd service to apply these rules on boot:

```bash
cat > /etc/systemd/system/openwrt-nat.service << 'EOF'
[Unit]
Description=NAT and forwarding for OpenWrt VM
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/sysctl -w net.ipv4.ip_forward=1
ExecStart=/sbin/iptables -t nat -A POSTROUTING -s 172.16.12.10/32 -o vmbr0 -j MASQUERADE
ExecStart=/sbin/iptables -A FORWARD -s 172.16.12.10/32 -j ACCEPT
ExecStart=/sbin/iptables -A FORWARD -d 172.16.12.10/32 -j ACCEPT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable openwrt-nat.service
```

## WiFi Config

The AX210 has **one physical radio** — it can do 2.4GHz OR 5GHz, not both simultaneously. Pick one.

### Option A: 5GHz (802.11ac/ax, faster, shorter range)

```
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'pci0000:00/0000:00:10.0'
        option band '5g'
        option channel '36'
        option htmode 'HE80'
        option country 'US'
        option txpower '20'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OpenWrt-5G'
        option encryption 'psk2'
        option key 'password123'
```

### Option B: 2.4GHz (802.11n, slower, longer range)

```
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'pci0000:00/0000:00:10.0'
        option band '2g'
        option channel '6'
        option htmode 'HT40'
        option country 'US'
        option txpower '20'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OpenWrt-2G'
        option encryption 'psk2'
        option key 'password123'
```

### Why not both bands?

The AX210 has one physical radio chip. 802.11n (2.4GHz) and 802.11ac (5GHz) require different frequencies — one radio can only be on one band at a time. For simultaneous dual-band AP, you need a second WiFi card or a router SoC with dual radios.

**iwinfo shows `Channel: 0`**: The wireless radio reports channel 0 when the regulatory domain isn't properly initialized. Setting `country 'US'` and running `wifi reload` fixes it.

**Known issue — driver crash on network restart**: Restarting `network` can trigger a `Microcode SW error` in iwlwifi. The driver self-recovers in ~2 seconds. Harmless but alarming in dmesg.

## Diagnostics

### VM not sending packets on eth0

```bash
# On Proxmox host — count packets on tap interface:
tcpdump -i tap100i0 -n -c 5

# If 0 packets — NIC driver issue. Switch from virtio to e1000.
# If packets but no NAT hits — wrong gateway. Check ip route in VM.
```

### WiFi card not detected in VM

```bash
# In VM:
dmesg | grep iwlwifi

# If nothing — image doesn't have iwlwifi. Rebuild with Image Builder.
# If "Detected" but no AP — check /etc/config/wireless.
```

### VM won't start after adding PCI passthrough

```bash
# Check dmesg on Proxmox:
dmesg | tail -20 | grep vfio-pci

# "not ready ... after FLR" → reset_method hookscript missing or reset_method not cleared
# "Unable to change power state from D3cold" → pcie_aspm=off missing from GRUB
# "Assertion pci_irq_handler failed" → remove pcie=1 from hostpci0
```

## Lessons Learned

| Problem | Cause | Fix |
|---|---|---|
| VM fails to boot | OVMF on BIOS-only image | Use `--bios seabios` |
| QEMU crashes with IRQ assertion | `pcie=1` on hostpci0 | Plain `--hostpci0 01:00.0` |
| VM hangs for 65s then stops | WiFi card FLR timeout | Hookscript clears reset_method |
| Card in D3cold, can't start | PCIe ASPM put card to sleep | `pcie_aspm=off` in GRUB cmdline |
| No packets on eth0 | Virtio driver zero-packet bug | Switch to e1000 NIC |
| No internet in VM | Gateway MAC-filters VM traffic | NAT through Proxmox host |
| NAT not working after reboot | iptables rules not persisted | systemd service `openwrt-nat.service` |
| NAT rules applied but no traffic | Missing FORWARD rules | Add `iptables -A FORWARD -s 172.16.12.10/32 -j ACCEPT` |
| Proxmox loses internet | NAT rule matched host traffic too | Scope MASQUERADE to `172.16.12.10/32` |
| Can't install kmods | Kernel version mismatch | Use stable 25.12.0, not snapshot |
| `apk update` fails with JSON error | No internet | Fix networking first |
