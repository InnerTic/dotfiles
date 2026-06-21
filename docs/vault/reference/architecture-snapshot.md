---
tags: [reference, architecture, network, proxmox, lxc]
aliases: [architecture-snapshot, current-architecture, homelab-architecture]
updated: 2026-06-20
---

# 🧭 Homelab Architecture Snapshot

Current system state — network topology, physical host, Proxmox, LXC, auth model, operational rules.

---

## 🌐 Network Topology

### Core network

```text
Router (OPNsense)
└── 172.16.1.1
    ├── DHCP range: 172.16.0.0/16 (dynamic devices)
    ├── Static infra zone: 172.16.5.x
    ├── Keeper/managed zone: 172.16.12.x
    └── Proxmox host: 172.16.7.1
```

### Design intent

* DHCP = ephemeral / experimental systems
* Static (.12.x) = stable "keeper" systems
* .5.x = infrastructure / services / core tools
* .7.x = virtualization layer (Proxmox control plane)

---

## 🖥️ Physical Host — Workstation / Control Node

```text
Hostname: Akuma
OS: CachyOS (Arch-based, KDE Plasma)
Shell: fish
Network interfaces:
  eth0 → 172.16.5.10 (bridged to vmbr0 on Proxmox network)
  wlan0 → backup / secondary uplink
```

### GPU setup

* NVIDIA RTX 3060 (host compute / desktop)
* NVIDIA Tesla P40 (VFIO passthrough capable)

---

## ⚙️ Proxmox VE Host

### System identity

```text
IP: 172.16.7.1
Bridge: vmbr0
Physical NIC: enp2s0
Gateway: 172.16.1.1
```

### Storage

| Storage   | Type      | Purpose                 |
| --------- | --------- | ----------------------- |
| local     | directory | ISO, templates, backups |
| local-lvm | LVM-thin  | VM/LXC root disks       |

---

## 🌉 Networking (Proxmox Layer)

### Bridge configuration

```text
vmbr0 = main bridge
└── enp2s0 (physical uplink)
    └── LAN access (OPNsense DHCP + routing)
```

### VM/LXC networking rule

All guests attach to vmbr0.
- DHCP for ephemeral systems.
- Static assignment via OPNsense for keepers.

---

## 📦 Container System (LXC)

### Current test container

```text
ID: 300
Hostname: quartz-test
OS: Debian 12
Network: vmbr0 (DHCP)
User: ken
SSH: enabled
```

### Role

* Agent sandbox
* Tool execution target
* Disposable compute environment

---

## 🔑 Authentication Model

### SSH keys

* Primary key: `id_rsa`
* Secondary key: `ed25519 (homelab)`

### Container auth state

* User: ken exists
* sudo enabled
* SSH installed
* authorized_keys configured
* password login fallback currently active (should be disabled after key fix confirmation)

### Key goal

* Move all access → key-based only
* Remove password auth once stable

---

## 🧪 Agent Testing Environment

### Current setup goal

Evaluate Hermes (or similar agent) behavior:
* Does it **execute tools**
* Or does it **simulate execution in text**

### Test container design

```text
300 = general sandbox
301 = future agent-dedicated sandbox (recommended)
```

### Safety pattern

* Always snapshot before agent use:

```bash
pct snapshot 300 baseline
```

* Rollback if needed:

```bash
pct rollback 300 baseline
```

---

## 🧠 VM/IP Mental Model

### Addressing logic

```text
DHCP pool        → temporary systems
172.16.12.x      → stable services / keepers
172.16.5.x       → infrastructure / core tooling
172.16.7.x       → Proxmox / virtualization layer
```

### Design philosophy

* IPs represent lifecycle state, not just location.
* "Keeper status" = manual promotion from DHCP → static.
* Proxmox does not enforce IP logic; OPNsense does.

---

## 🧩 Known Issues (Resolved)

### SSH key issue (quartz-test)

* Problem: authorized_keys file misnamed (`authorized_keysssh-rsa`).
* Fix: rename → `authorized_keys`.
* Result: SSH key auth works; password fallback previously triggered by missing key file.

---

## ⚡ Tesla P40 Status

### Hardware state

```text
GPU: Tesla P40 (GP102GL)
Driver mode: VFIO active
IOMMU group: isolated but complex grouping present
```

GPU passthrough is functional but tightly coupled to IOMMU group constraints. Some chipset devices share groups (normal AMD behavior).

---

## 🧪 Proxmox VM/LXC Workflow

### Standard creation flow

```text
1. Create LXC/VM
2. Attach to vmbr0
3. Use DHCP initially
4. Validate access
5. Promote to static IP (if keeper)
6. Snapshot baseline
```

---

## 🧭 Operational Rules

### Networking

* Always use vmbr0 for guests.
* Never bypass OPNsense unless explicitly testing.

### Containers

* Treat LXC 300+ as experimental space.
* Snapshot before agent execution.

### Agents

* Must be forced to use tools explicitly.
* Never trust "described execution" without system verification.

---

## 🧷 Recommended Next Step

### Create dedicated agent sandbox

```text
301 = hermes-agent
```

With:
* No sensitive mounts
* No Proxmox host access
* Strict SSH-only control
* Snapshot rollback loop
