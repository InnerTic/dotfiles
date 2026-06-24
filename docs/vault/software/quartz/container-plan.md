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
| IP | `172.16.12.17` |
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

## Phase 2: Verify Versions (before any install)

```bash
cat /etc/os-release
node -v || true
npm -v || true
python3 --version || true
pip --version || true
```

Compare against application requirements. See `docs/reference/software-version-requirements.md`.

## Phase 3: Base Packages

```bash
sudo apt update
sudo apt install -y git curl wget rsync ca-certificates unzip build-essential
```

## Phase 4: Directory Layout

```bash
sudo mkdir -p /srv/{vault,quartz,backups}
sudo chown -R ken:ken /srv/{vault,quartz,backups}
```

## Phase 5: Install Node.js

```bash
sudo apt remove -y nodejs npm 2>/dev/null || true
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v && npm -v
```

## Phase 6: Install pnpm

```bash
sudo npm install -g pnpm
pnpm -v
```

## Phase 7: Clone Quartz

```bash
cd /srv
git clone https://github.com/jackyzha0/quartz.git quartz-src
cd quartz-src
pnpm install
pnpm quartz --help
```

## Phase 8: Site Working Copy

```bash
cp -a /srv/quartz-src /srv/quartz
```

Result:

```
/srv/quartz-src   ← upstream reference (clean)
/srv/quartz       ← actual site (edit here)
```

## Phase 9: Connect Vault

```bash
cd /srv/vault
git clone git@github.com:InnerTic/dotfiles.git .
```

**Note:** Content lives at `/srv/vault/docs/` — will need an extra rsync step to map to `/srv/quartz/content/`, or symlink.

## Phase 10: Sync Vault → Quartz Content

```bash
rsync -av --delete /srv/vault/ /srv/quartz/content/
ls /srv/quartz/content
```

## Phase 11: Build

```bash
cd /srv/quartz
pnpm quartz build
ls public
```

## Phase 12: Test Locally

```bash
cd /srv/quartz
pnpm quartz serve
```

Visit `http://172.16.12.17:8080` from desktop. Cmd+C to stop.

## Phase 13: Install Caddy

```bash
sudo apt install -y caddy
```

## Phase 14: Configure Caddy

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

## Phase 15: Verify

Visit `http://172.16.12.17` from desktop.

## Phase 16: DNS

```
wiki.home.arpa → 172.16.12.17
```

In `/etc/hosts` on Akuma as fallback:

```
172.16.12.17 wiki.home.arpa quartz
```

## Phase 17: Update Script

`~/dotfiles/scripts/update-quartz.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd /srv/vault && git pull
rsync -av --delete /srv/vault/ /srv/quartz/content/
cd /srv/quartz && pnpm quartz build
```

```bash
chmod +x ~/dotfiles/scripts/update-quartz.sh
```

Usage: `./dotfiles/scripts/update-quartz.sh`

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

## Phase 18: Status Endpoint

Install `~/dotfiles/scripts/quartz/generate-status.sh` — emits `status.json` after each build:

```json
{
  "status": "ok",
  "time": "2026-06-23T23:10:00-07:00",
  "files": 42,
  "git": { "commit": "a1b2c3d", "branch": "main" },
  "vault": { "commit": "e4f5g6h", "branch": "deb" },
  "runtime": { "node": "v22.14.0", "npm": "10.9.2" }
}
```

The update script (`scripts/update-quartz.sh`) already runs it after every build.

Add to Caddyfile (`/etc/caddy/Caddyfile`):

```
:80 {
    root * /srv/quartz/public
    file_server

    @status {
        path /status
    }
    handle @status {
        root * /srv/quartz/public
        file_server
    }
}
```

Or for nginx, use the snippet at `scripts/quartz/nginx-status.conf`.

Test:

```bash
curl http://localhost/status
```

## Snapshot Points

```bash
pct snapshot 301 node-installed
pct snapshot 301 quartz-installed
pct snapshot 301 caddy-working
pct snapshot 301 first-sync-working
pct snapshot 301 status-endpoint
```

## Directory Layout (final)

```
/srv/
├── backups/
├── vault/           ← git repo, docs/
├── quartz/          ← Quartz site, content/ → public/
│   └── public/
│       ├── index.html
│       └── status.json   ← self-observation
└── quartz-src/     ← upstream (reference only)
```

## Key Constraints

- Canonical docs: `~/dotfiles/docs` — never edit generated files
- Quartz content dir is a disposable copy (rsync --delete)
- No hardcoded IPs in markdown content
- Container serves wiki, does not initiate connections to host
- Status endpoint makes the container self-observable — AI tooling can check `/status` before triggering rebuilds

## Open Questions

1. **Trigger method** — Manual script (`scripts/update-quartz.sh`), or automate via git hook / systemd path unit?
2. **DNS** — OPNsense reservation (`172.16.12.17` → `wiki.home.arpa`) or `/etc/hosts` on Akuma?
3. **Push deploy** — Host-side script to rsync content + SSH trigger build, or let the container pull from git?
