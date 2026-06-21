---
tags: [reference, security, ssh, ai, proxmox, lxc]
aliases: [ai-ssh, agent-safe-ssh, restricted-ssh, ai-access]
updated: 2026-06-20
---

# 🧩 AI SSH Architecture — Restricted Access for LXCs

Goal: AI can SSH into LXCs safely — no root, no shared keys, auditable actions.

---

## Architecture

```
Human (you)
    │
    ├── SSH root (Proxmox admin)
    │
    ▼
Proxmox
    │
    ├── creates LXCs
    ├── injects per-container SSH keys
    │
    ▼
LXCs
    │
    ├── ai-user (restricted)
    ├── root (disabled for SSH)
    │
    ▼
AI agent
    ├── SSH into ai-user only
    ├── executes bounded scripts only
```

---

## 🔐 Step 1 — Dedicated AI user per LXC

Inside LXC template or bootstrap script:

```bash
useradd -m -s /bin/bash ai
```

Lock down root SSH:

```bash
passwd -l root
```

Edit `/etc/ssh/sshd_config`:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers ai
```

Restart SSH:

```bash
systemctl restart ssh
```

---

## 🔑 Step 2 — AI-specific SSH key

On your control machine — do NOT share your personal key:

```bash
ssh-keygen -t ed25519 -C "ai-agent"
```

Produces `~/.ssh/id_ed25519_ai` (private) and `~/.ssh/id_ed25519_ai.pub` (public).

---

## 📦 Step 3 — Inject AI key into LXCs

During provisioning:

```bash
mkdir -p /home/ai/.ssh
cat ~/.ssh/id_ed25519_ai.pub >> /home/ai/.ssh/authorized_keys
chown -R ai:ai /home/ai/.ssh
chmod 700 /home/ai/.ssh
chmod 600 /home/ai/.ssh/authorized_keys
```

---

## 🧱 Step 4 — Restrict AI commands

Create a command wrapper at `/usr/local/bin/ai-run`:

```bash
#!/bin/bash

# Only allow known scripts
case "$1" in
  status) systemctl status "$2" ;;
  logs) journalctl -u "$2" ;;
  update) apt update && apt upgrade -y ;;
  *) echo "Blocked command" ; exit 1 ;;
esac
```

```bash
chmod +x /usr/local/bin/ai-run
```

The AI cannot run arbitrary commands — only approved actions.

---

## 🧠 Step 5 — AI SSH access pattern

Instead of `ssh root@lxc`, the AI does:

```bash
ssh ai@lxc "ai-run status nginx"
ssh ai@lxc "ai-run logs nginx"
ssh ai@lxc "ai-run update"
```

---

## 🧠 Step 6 — Optional Proxmox-level restriction

In `/etc/ssh/sshd_config` on the Proxmox host:

```
PermitRootLogin prohibit-password
```

Key separation:
- Human key → full root on Proxmox
- AI key → only allowed to access LXCs as `ai`

---

## 🧠 What this gives you

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

Without these constraints, AI SSH access is a scriptable root shell with memory.  
With them, it is a controlled operator with a limited toolbelt.
