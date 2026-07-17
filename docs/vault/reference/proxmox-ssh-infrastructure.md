# Proxmox SSH Infrastructure & AI Agent Access

## Overview

A keyed infrastructure mesh where identity = SSH key, trust = auto-injected keys, control = Proxmox + scripts, state = Git + vault + AI logs.

```
            HUMAN
              │
   full control SSH key
              │
        PROXMOX HOST
              │
   per-container provisioning
              │
        LXC ENVIRONMENTS
              │
        ai user account
              │
     restricted command layer
              │
            AI AGENT
```

---

## Step 1 — Install Key on Proxmox

```bash
ssh-copy-id root@172.16.7.1
```

Or manually:

```bash
cat ~/.ssh/id_ed25519.pub | ssh root@172.16.7.1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Test:

```bash
ssh root@172.16.7.1
```

---

## Step 2 — Proxmox as Key-Aware Agent Host

On Proxmox:

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
```

Store your public key centrally:

```bash
cat >> /root/.ssh/authorized_keys
# paste your key
```

---

## Step 3 — Auto-Inject SSH Key into Every New LXC

### 3.1 Create hook script

`/var/lib/vz/snippets/ssh-inject.sh`:

```bash
#!/bin/bash
KEY="$(cat /root/.ssh/authorized_keys)"
mkdir -p /target/root/.ssh
echo "$KEY" >> /target/root/.ssh/authorized_keys
chmod 700 /target/root/.ssh
chmod 600 /target/root/.ssh/authorized_keys
```

```bash
chmod +x /var/lib/vz/snippets/ssh-inject.sh
```

### 3.2 Attach hook to LXC creation

```bash
pct create 200 local:vztmpl/debian-12-standard_*.tar.zst \
  --hostname quartz \
  --ssh-public-keys /root/.ssh/authorized_keys \
  --features nesting=1 \
  --hookscript local:snippets/ssh-inject.sh
```

---

## Step 4 — Embed SSH Trust in lxc-bootstrap.sh

Add near top of bootstrap:

```bash
# ── SSH bootstrap ─────────────────────────────
echo ">>> Installing SSH key access..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [ ! -f /root/.ssh/authorized_keys ]; then
    touch /root/.ssh/authorized_keys
fi
cat ~/.ssh/authorized_keys >> /root/.ssh/authorized_keys 2>/dev/null || true
chmod 600 /root/.ssh/authorized_keys
```

---

## Step 5 — SSH Agent Map (Control System Layer)

`~/.ssh/config`:

```
Host proxmox
    HostName 172.16.7.1
    User root
    IdentityFile ~/.ssh/id_ed25519

Host lxc-*
    User root
    IdentityFile ~/.ssh/id_ed25519
```

Usage:

```bash
ssh proxmox
ssh lxc-quartz
ssh lxc-wiki
```

---

## Step 6 — Control System Topology

```
                +----------------+
                |  MX Linux      |
                |  (control)     |
                +-------+--------+
                        |
                        | SSH keys
                        v
                +----------------+
                |  Proxmox       |
                |  (orchestrator)|
                +-------+--------+
                        |
            +-----------+-----------+
            |           |           |
            v           v           v
        LXC Quartz   LXC Wiki   LXC AI tools
        (SSH ready)  (SSH ready) (SSH ready)
```

Every new container: automatically reachable, automatically scriptable, automatically consistent.

---

## Step 7 — AI Agent SSH Access (Restricted)

### 7.1 Create AI user inside each LXC

```bash
useradd -m -s /bin/bash ai
passwd -l root
```

`/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers ai
```

```bash
systemctl restart ssh
```

### 7.2 Generate AI-specific SSH key

```bash
ssh-keygen -t ed25519 -C "ai-agent"
# produces ~/.ssh/id_ed25519_ai
```

### 7.3 Inject AI key into LXCs

```bash
mkdir -p /home/ai/.ssh
cat >> /home/ai/.ssh/authorized_keys
# paste ~/.ssh/id_ed25519_ai.pub
chown -R ai:ai /home/ai/.ssh
chmod 700 /home/ai/.ssh
chmod 600 /home/ai/.ssh/authorized_keys
```

### 7.4 Restricted command wrapper

`/usr/local/bin/ai-run`:

```bash
#!/bin/bash
case "$1" in
  status) systemctl status "$2" ;;
  logs)   journalctl -u "$2" ;;
  update) apt update && apt upgrade -y ;;
  *)      echo "Blocked command" ; exit 1 ;;
esac
```

```bash
chmod +x /usr/local/bin/ai-run
```

AI access pattern:

```bash
ssh ai@lxc "ai-run status nginx"
ssh ai@lxc "ai-run logs nginx"
ssh ai@lxc "ai-run update"
```

### 7.5 Proxmox-level restriction

`/etc/ssh/sshd_config`:

```
PermitRootLogin prohibit-password
```

Split keys:
- human key → full root
- AI key → only allowed to access LXCs as `ai`

---

## Design Rules

- No root login for the AI
- No shared master key
- No unrestricted command execution
- Each LXC has a scoped identity
- Actions are auditable
- Without constraints, AI SSH is "a scriptable root shell with memory"
- With constraints, it becomes "a controlled operator with a limited toolbelt"
