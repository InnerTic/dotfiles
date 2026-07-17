---
tags: [virtualization, kvm, networking]
aliases: [kvm-bridge, bridge-networking, libvirt-setup]
updated: 2026-06-19
---

# Debian KVM + Bridge Networking (libvirt + virt-manager)

Clean baseline setup for running VMs on Debian using **KVM/QEMU + libvirt**, with **VMs receiving DHCP from the physical LAN router** (no NAT networking).

---

## 1. Install full virtualization stack

```bash
sudo apt update

sudo apt install -y \
qemu-system \
qemu-utils \
qemu-kvm \
libvirt-daemon-system \
libvirt-clients \
virtinst \
virt-manager \
virt-viewer \
bridge-utils \
dnsmasq-base \
ovmf \
swtpm \
guestfs-tools \
cloud-image-utils
```

Optional diagnostics:

```bash
sudo apt install -y \
cpu-checker \
virt-top \
pciutils \
usbutils \
hwloc
```

---

## 2. Enable libvirt service

```bash
sudo systemctl enable --now libvirtd
```

Verify:

```bash
systemctl status libvirtd
```

---

## 3. Add user permissions

```bash
sudo usermod -aG libvirt,kvm $USER
```

Log out and back in. Verify:

```bash
groups
```

---

## 4. Verify KVM acceleration

```bash
kvm-ok
```

Or:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

---

## 5. Verify default libvirt network (optional)

```bash
virsh net-list --all
```

The default NAT network (`virbr0`) can remain but is not required for bridged setups.

---

## 6. Create a Linux bridge (NetworkManager method)

Replaces direct host networking on `eth0` with a bridge (`br0`).

### 6.1 Create bridge

```bash
sudo nmcli connection add type bridge ifname br0 con-name br0
```

### 6.2 Enable DHCP on bridge

```bash
sudo nmcli connection modify br0 ipv4.method auto
sudo nmcli connection modify br0 ipv6.method auto
```

### 6.3 Attach physical NIC to bridge

```bash
sudo nmcli connection add \
type bridge-slave \
ifname eth0 \
master br0
```

### 6.4 Disable direct Ethernet profile

```bash
sudo nmcli connection modify "Wired connection 1" connection.autoconnect no
```

### 6.5 Bring bridge up

```bash
sudo nmcli connection up br0
```

---

## 7. Verify network state

```bash
ip -br addr
ip route
nmcli device status
```

Expected:
- `br0` holds host IP
- `eth0` is a bridge slave (no IP)
- default route uses `br0`

---

## 8. Optional: disable WiFi default route interference

If WiFi is present and active:

```bash
sudo nmcli connection modify wlan0 ipv4.never-default yes
sudo nmcli connection modify wlan0 ipv6.never-default yes
```

---

## 9. VM networking configuration (libvirt)

VMs must use the Linux bridge.

### virt-manager method

For each VM:
- Open VM → Hardware details
- Network interface
- Change:
  - Source: **Bridge device**
  - Device name: `br0`

### Result

VMs will:
- Receive IP addresses from the LAN router (DHCP)
- Appear as physical machines on the network
- Avoid NAT (`192.168.122.x`)
- Be directly reachable via SSH/services

---

## 10. Network model

```
Router (DHCP)
    │
    ▼
br0 (Debian host)
    │
    ├── eth0 (physical link)
    ├── VM1 (DHCP from router)
    ├── VM2 (DHCP from router)
    └── VM3 (DHCP from router)
```

---

## Key concept

- **NetworkManager bridge (`br0`)** = real network layer (required)
- **libvirt bridge setting** = VM attachment method
- **virbr0 NAT network** = not used in this setup

---

## Outcome

This configuration turns a Debian desktop into a lightweight hypervisor where:
- VMs behave like physical devices on the LAN
- No NAT or port forwarding is required
- DHCP is handled entirely by the existing router
- libvirt only manages lifecycle, not networking topology

---

# CachyOS / Arch — Clean Bridge Setup

Reboot-safe, zero-touch libvirt VM host profile for Arch-based systems.
Same end state (bridged `br0`, LAN DHCP), but with corrected package and nmcli setup.

## What's different from Debian

- `bridge-utils` **does not exist** in Arch repos — bridge tooling is in `iproute2` + kernel module + NetworkManager
- `nmcli` requires `type bridge-slave`, not `type ethernet master br0`
- MAC binding can go stale — force DHCP renewal when switching to bridge

## 1. Install correct packages

```bash
sudo pacman -S --needed \
    qemu-full \
    libvirt \
    virt-manager \
    dnsmasq \
    edk2-ovmf \
    iptables-nft \
    iproute2
```

If `bridge-utils` errors from a prior install, remove:
```bash
sudo pacman -R bridge-utils 2>/dev/null
```

## 2. Enable services

```bash
sudo systemctl enable --now libvirtd
sudo systemctl enable --now NetworkManager
```

## 3. Create clean bridge (delete broken profiles first)

```bash
sudo nmcli connection delete br0 2>/dev/null
sudo nmcli connection delete br0-port 2>/dev/null

sudo nmcli connection add \
    type bridge \
    ifname br0 \
    con-name br0

sudo nmcli connection modify br0 \
    ipv4.method auto \
    ipv6.method auto
```

## 4. Attach NIC as bridge-slave (not master)

```bash
sudo nmcli connection add \
    type bridge-slave \
    ifname enp6s0 \
    master br0 \
    con-name br0-enp6s0
```

## 5. Bring up

```bash
sudo nmcli connection up br0
sudo nmcli connection up br0-enp6s0
```

## 6. Verify

```bash
ip a show br0
```

Expected: `inet 172.16.x.x/16 dynamic`, `state UP`, NIC shows `master br0`.

## 7. Force DHCP refresh if MAC binding is stale

```bash
sudo nmcli connection down br0
sudo nmcli connection up br0
```

Hard reset:
```bash
sudo dhclient -r br0
sudo dhclient br0
```

## 8. Disable libvirt NAT (optional)

If you want pure bridge, no `virbr0`:
```bash
sudo virsh net-destroy default
sudo virsh net-autostart default --disable
```

## 9. VM NIC config (virt-manager)

- NIC source: **Bridge device**
- Device name: `br0`
- Model: `virtio`

## 10. Reboot-safe persistence

```bash
sudo systemctl enable NetworkManager
sudo systemctl enable libvirtd
```

## Key corrections (vs failed attempts)

| Issue | Fix |
|-------|-----|
| `bridge-utils` missing | removed dependency assumption |
| nmcli controller error | replaced with proper bridge-slave |
| enp6s0 modify failure | corrected connection vs device confusion |
| MAC binding stale | forced DHCP renewal strategy |
| bridge DOWN state | clarified normal behavior |
| mixed connection types | normalized NetworkManager model |
