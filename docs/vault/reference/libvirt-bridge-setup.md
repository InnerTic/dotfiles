---
tags: [reference, virtualization, libvirt, networking, bridge]
aliases: [libvirt-bridge, vm-bridge, br0-setup]
updated: 2026-06-19
---

# Libvirt VM Host — Bridged Networking (CachyOS/Arch)

Clean, reboot-safe, zero-touch libvirt VM host profile for CachyOS.
VMs get DHCP directly from router via bridge — no NAT, no `virbr0`.

## Target State

- **Host OS:** CachyOS (Arch-based)
- **Network mode:** Bridged networking (`br0`)
- **IP source:** Router DHCP (172.16.1.1 / LAN)
- **VM behavior:** Identical to physical devices on LAN
- **Persistence:** NetworkManager + libvirt autostart
- No NAT, no `virbr0` reliance (optional disabled)

---

## What was wrong

### `bridge-utils` error
Package does not exist anymore in Arch repos. Bridge tooling is in `iproute2`, kernel bridge module, and NetworkManager.

### nmcli controller error
Mixing `type ethernet master br0` instead of `type bridge-slave` or `connection type bridge-port`.

### Bridge showed DOWN / NO-CARRIER
Normal if cable not actively passing traffic or DHCP lease not yet bound.

### MAC binding stale
DHCP leases are sticky — MAC change does not mean immediate renewal. Force DHCP renewal or MAC change + restart network.

---

## Clean Install

### 1. Install correct packages

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

If `bridge-utils` errors, ignore safely:
```bash
sudo pacman -R bridge-utils 2>/dev/null
```

### 2. Enable virtualization services

```bash
sudo systemctl enable --now libvirtd
sudo systemctl enable --now NetworkManager
```

### 3. Create clean bridge (br0)

Delete any broken profiles first:
```bash
sudo nmcli connection delete br0 2>/dev/null
sudo nmcli connection delete br0-port 2>/dev/null
```

Create bridge:
```bash
sudo nmcli connection add \
    type bridge \
    ifname br0 \
    con-name br0
```

Set DHCP on bridge:
```bash
sudo nmcli connection modify br0 \
    ipv4.method auto \
    ipv6.method auto
```

### 4. Attach physical NIC (bridge-slave)

```bash
sudo nmcli connection add \
    type bridge-slave \
    ifname enp6s0 \
    master br0 \
    con-name br0-enp6s0
```

### 5. Bring everything up

```bash
sudo nmcli connection up br0
sudo nmcli connection up br0-enp6s0
```

### 6. Verify bridge

```bash
ip a show br0
```

Expected: `inet 172.16.x.x/16 dynamic`, `state UP`, NIC shows `master br0`.

### 7. Force DHCP refresh (fix stale MAC leases)

```bash
sudo nmcli connection down br0
sudo nmcli connection up br0
```

Hard reset:
```bash
sudo dhclient -r br0
sudo dhclient br0
```

---

## Libvirt side — disable NAT, use bridge

```bash
sudo virsh net-destroy default
sudo virsh net-autostart default --disable
```

In virt-manager for each VM:
- NIC source: **Bridge device**
- Device name: `br0`
- Model: `virtio`

---

## Reboot-safe guarantee

```bash
sudo systemctl enable NetworkManager
sudo systemctl enable libvirtd
```

## Final validation

After reboot:
```bash
ip a show br0
nmcli connection show --active
```

Inside VM:
```bash
ip a
```

Expected: IP from router DHCP (172.16.1.x), same subnet as host, no 192.168.122.x NAT ranges.

---

## Key corrections

| Issue | Fix |
|-------|-----|
| `bridge-utils` missing | removed dependency assumption |
| nmcli controller error | replaced with proper bridge-slave |
| enp6s0 modify failure | corrected connection vs device confusion |
| MAC binding stale | forced DHCP renewal strategy |
| bridge DOWN state | clarified normal behavior |
| mixed connection types | normalized NetworkManager model |

## Related

- [[system/drives-and-mounts]] — Drive layout for VM storage (sde3)
- [[system/dual-boot-recovery]] — Boot recovery
- [[reference/faq]] — Common questions
