---
tags: [reference, proxmox, lxc, build-log]
aliases: [lxc-build-log, quartz-test-build, container-build, proxmox-lxc-build]
updated: 2026-06-20
---

# 🧱 Proxmox LXC Build Log — quartz-test (300)

Full build sequence for LXC 300, end-to-end.

---

## 0. Host access

```bash
ssh root@172.16.7.1
```

or direct:

```bash
pct exec 300 ...
```

---

## 1. Verify storage

```bash
pvesm status
```

Expected:
- `local` (dir)
- `local-lvm` (thin)

---

## 2. Update template index

```bash
pveam update
```

---

## 3. Download Debian 12 template

```bash
pveam available | grep debian-12
pveam download local debian-12-standard_12.7-1_amd64.tar.zst
```

Verify:

```bash
ls /var/lib/vz/template/cache/
```

---

## 4. Create LXC container (quartz-test)

```bash
pct create 300 \
  local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname quartz-test \
  --cores 2 \
  --memory 2048 \
  --swap 512 \
  --rootfs local-lvm:8 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --unprivileged 1 \
  --features nesting=1
```

---

## 5. Start container

```bash
pct start 300
```

Verify:

```bash
pct list
```

---

## 6. Find container IP

```bash
pct exec 300 -- hostname -I
```

or:

```bash
pct exec 300 -- ip -br addr
```

---

## 7. Enter container shell (optional)

```bash
pct enter 300
```

---

## 8. Create user `ken`

```bash
pct exec 300 -- useradd -m -s /bin/bash ken
```

Set password:

```bash
pct exec 300 -- bash -c "echo 'ken:YOUR_PASSWORD' | chpasswd"
```

---

## 9. Add sudo

```bash
pct exec 300 -- apt update
pct exec 300 -- apt install -y sudo
pct exec 300 -- usermod -aG sudo ken
```

---

## 10. Install base tooling

```bash
pct exec 300 -- apt install -y \
  curl \
  wget \
  git \
  vim \
  nano \
  htop \
  openssh-server \
  ca-certificates
```

---

## 11. Enable SSH

```bash
pct exec 300 -- systemctl enable ssh
pct exec 300 -- systemctl start ssh
```

---

## 12. Install SSH key

### Create `.ssh` directory

```bash
pct exec 300 -- mkdir -p /home/ken/.ssh
```

### Paste key (manual)

```bash
pct exec 300 -- nano /home/ken/.ssh/authorized_keys
```

> ⚠️ Initial mistake: file created as `authorized_keysssh-rsa` (wrong name).

### Fix (rename + permissions)

```bash
pct exec 300 -- mv /home/ken/.ssh/authorized_keysssh-rsa /home/ken/.ssh/authorized_keys
pct exec 300 -- chmod 700 /home/ken/.ssh
pct exec 300 -- chmod 600 /home/ken/.ssh/authorized_keys
pct exec 300 -- chown -R ken:ken /home/ken/.ssh
```

---

## 13. Create working directories

```bash
pct exec 300 -- mkdir -p \
  /srv/data \
  /srv/apps \
  /srv/backups \
  /srv/shared
```

---

## 14. Fix ownership model

```bash
pct exec 300 -- chown -R ken:ken /srv/data
pct exec 300 -- chown -R ken:ken /srv/apps
pct exec 300 -- chown root:root /srv/shared
pct exec 300 -- chmod 755 /srv/shared
```

---

## 15. Add optional group workspace

```bash
pct exec 300 -- groupadd admins
pct exec 300 -- usermod -aG admins ken
pct exec 300 -- mkdir -p /srv/workspace
pct exec 300 -- chown root:admins /srv/workspace
pct exec 300 -- chmod 2775 /srv/workspace
```

---

## 16. Snapshot baseline

```bash
pct snapshot 300 baseline
```

Verify:

```bash
pct listsnapshot 300
```

---

## 17. SSH test (final validation)

```bash
ssh ken@quartz-test
```

Expected: key-based login (password fallback initially before key fix).

---

## Scripts

| Script | Run from | What it does |
|--------|----------|-------------|
| `scripts/build-gold-lxc.sh` | Proxmox host | Builds gold template (VMID 9000) — `pct create` + install + `pct template` |
| `scripts/lxc-provision.sh` | Proxmox host | Creates+configures a single container from template (includes SSH key, /srv, snapshot) |
| `scripts/lxc-bootstrap.sh` | Inside container | Shell environment setup — fish/zsh/fonts/aliases |

### Gold image pipeline (recommended)

```bash
# One-time: build gold template
./build-gold-lxc.sh

# Then clone in seconds
pct clone 9000 300 --hostname quartz-test --full
pct set 300 -net0 name=eth0,bridge=vmbr0,ip=dhcp
pct start 300

pct clone 9000 301 --hostname hermes-sandbox --full
pct set 301 -net0 name=eth0,bridge=vmbr0,ip=dhcp
pct start 301
```

The gold image (`pct template 9000`) becomes read-only. Every clone is identical — no install-time drift, no runtime differences.

---

## 🧠 Key Lessons

### 1. Key auth failure root cause
`authorized_keysssh-rsa` → wrong filename. Must be `authorized_keys`.

### 2. Proxmox LXC networking rule
All containers attach to `vmbr0`. IP comes from OPNsense DHCP unless overridden.

### 3. Agent-safe design pattern
Create → configure → snapshot → then allow agent access.
