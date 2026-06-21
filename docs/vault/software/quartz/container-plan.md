# Quartz Container Plan — v2

Move Quartz from host into a dedicated LXC container.

## Target Architecture

```
Obsidian Vault (desktop)
        │
        ▼
Git Repository
        │
        ▼
Quartz Container (301)
    /srv/vault       ← vault content
    /srv/quartz      ← Quartz site (build output)
        │
        ▼
Caddy
        │
        ▼
http://wiki.home.arpa
```

## Container

| Property | Value |
|----------|-------|
| LXC ID | 301 |
| Hostname | quartz-base (existing, running) |
| IP | `172.16.1.44` |
| User | `ken` (present) |
| Shell | bash |

## Phase 0: Snapshot First

```bash
pct snapshot 301 pre-quartz-install
pct listsnapshot 301
```

## Phase 1: Enter Container

```bash
ssh ken@172.16.1.44
```

## Phase 2: Base Packages

```bash
sudo apt update
sudo apt install -y git curl wget rsync ca-certificates unzip build-essential
```

## Phase 3: Directory Layout

```bash
sudo mkdir -p /srv/{vault,quartz,backups}
sudo chown -R ken:ken /srv/{vault,quartz,backups}
```

## Phase 4: Install Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v && npm -v
```

## Phase 5: Install pnpm

```bash
sudo npm install -g pnpm
pnpm -v
```

## Phase 6: Clone Quartz

```bash
cd /srv
git clone https://github.com/jackyzha0/quartz.git quartz-src
cd quartz-src
pnpm install
pnpm quartz --help
```

## Phase 7: Site Working Copy

```bash
cp -a /srv/quartz-src /srv/quartz
```

Result:

```
/srv/quartz-src   ← upstream reference (clean)
/srv/quartz       ← actual site (edit here)
```

## Phase 8: Connect Vault

```bash
cd /srv/vault
git clone git@github.com:InnerTic/dotfiles.git .
```

**Note:** Content lives at `/srv/vault/docs/` — will need an extra rsync step to map to `/srv/quartz/content/`, or symlink.

## Phase 9: Sync Vault → Quartz Content

```bash
rsync -av --delete /srv/vault/ /srv/quartz/content/
ls /srv/quartz/content
```

## Phase 10: Build

```bash
cd /srv/quartz
pnpm quartz build
ls public
```

## Phase 11: Test Locally

```bash
cd /srv/quartz
pnpm quartz serve
```

Visit `http://172.16.1.44:8080` from desktop. Cmd+C to stop.

## Phase 12: Install Caddy

```bash
sudo apt install -y caddy
```

## Phase 13: Configure Caddy

`/etc/caddy/Caddyfile`:

```
:80 {
    root * /srv/quartz/public
    file_server
}
```

```bash
sudo systemctl restart caddy
sudo systemctl status caddy
```

## Phase 14: Verify

Visit `http://172.16.1.44` from desktop.

## Phase 15: DNS

```
wiki.home.arpa → 172.16.1.44
```

In `/etc/hosts` on Akuma as fallback:

```
172.16.1.44 wiki.home.arpa quartz
```

## Phase 16: Update Script

`~/update-wiki.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /srv/vault && git pull
rsync -av --delete /srv/vault/ /srv/quartz/content/
cd /srv/quartz && pnpm quartz build
```

```bash
chmod +x ~/update-wiki.sh
```

Usage: `./update-wiki.sh`

## Snapshot Points

```bash
pct snapshot 301 node-installed
pct snapshot 301 quartz-installed
pct snapshot 301 caddy-working
pct snapshot 301 first-sync-working
```

## Directory Layout (final)

```
/srv/
├── backups/
├── vault/           ← git repo, docs/
├── quartz/          ← Quartz site, content/ → public/
└── quartz-src/     ← upstream (reference only)
```

## Key Constraints

- Canonical docs: `~/dotfiles/docs` — never edit generated files
- Quartz content dir is a disposable copy (rsync --delete)
- No hardcoded IPs in markdown content
- Container serves wiki, does not initiate connections to host

## Open Questions

1. **Vault content path** — Obsidian vault is `~/dotfiles/docs/`, content dir is `/srv/quartz/content/`. Rsync or symlink?
2. **Trigger method** — Manual script, systemd path unit, or git hook?
3. **DNS** — OPNsense reservation or `/etc/hosts` on Akuma?
4. **Push deploy** — Host-side `deploy-quartz` script to rsync + ssh trigger, or container pulls?
