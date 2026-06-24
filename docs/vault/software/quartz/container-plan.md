# Quartz Container Plan — v3

Move Quartz from host into a dedicated LXC container.

## Target Architecture

```
SOURCE OF TRUTH
Obsidian → Git repo (~/dotfiles/docs)

        ↓

BUILD LAYER (LXC 301)
/srv/vault          ← git clone (source)
/srv/quartz         ← working instance, content/ + public/

        ↓

DELIVERY LAYER (same LXC)
nginx — serves /srv/quartz/public

        ↓

http://wiki.home.arpa
```

A **3-layer publishing system**: Git (truth) → Quartz build (pure function) → static output → nginx (dumb server).

The container is **never** a source of truth.

## Container

| Property | Value |
|----------|-------|
| LXC ID | 301 (auto-increments if taken) |
| Hostname | quartz-base |
| IP | DHCP (current lease: `172.16.12.17`) |
| User | `ken` (present, NOPASSWD sudo) |
| Shell | bash |
| Base | Ubuntu 24.04 LTS |

## Phase 0: Snapshot First

```bash
pct snapshot 301 pre-quartz-install
pct listsnapshot 301
```

## Phase 1: Enter Container

Find the DHCP lease:

```bash
pct list
```

Or get the IP directly:

```bash
pct enter 301
hostname -I
```

Then SSH in:

```bash
ssh ken@<container-ip>
```

## Phase 2: Verify Versions

```bash
cat /etc/os-release
node -v || true
npm -v || true
```

Compare against `docs/reference/software-version-requirements.md`.

## Phase 3: Base Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget rsync ca-certificates unzip build-essential
```

## Phase 4: NOPASSWD Sudo

```bash
echo "ken ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ken
```

Log out and back in, then verify:

```bash
sudo -n true && echo "ok"
```

## Phase 5: Install Node.js 22 LTS

```bash
sudo apt remove -y nodejs npm 2>/dev/null || true
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v && npm -v
```

**npm only** — no pnpm. Quartz v5 is npm-first.

## Phase 6: Directory Layout

```bash
sudo mkdir -p /srv/{vault,quartz,backups}
sudo chown -R ken:ken /srv/{vault,quartz,backups}
```

## Phase 7: Clone Quartz (Single Instance)

```bash
cd /srv
git clone https://github.com/jackyzha0/quartz.git quartz
cd quartz
npm install
```

**No `cp -a` duplication.** `/srv/quartz` is the single working instance.

## Phase 8: Create Content Directory

```bash
mkdir -p /srv/quartz/content
```

## Phase 9: Connect Vault

```bash
cd /srv/vault
git clone https://github.com/InnerTic/dotfiles.git .
```

Content lives at `/srv/vault/docs/` — the `docs/` subdirectory is the content source unit.

## Phase 10: Sync Vault → Quartz Content

```bash
rsync -av --delete /srv/vault/docs/ /srv/quartz/content/
```

**Note:** rsync `docs/` not `vault/` — avoids pulling `.git/`, config files, and unrelated repo artefacts.

## Phase 11: Build

```bash
cd /srv/quartz
npx quartz build
ls public/index.html
```

## Phase 12: Test Locally

```bash
cd /srv/quartz
npx quartz serve
```

Visit `http://<container-ip>:8080` from desktop. Ctrl+C to stop.

## Phase 13: Install & Configure nginx

```bash
sudo apt install -y nginx
```

Create `/etc/nginx/sites-available/quartz`:

```nginx
server {
    listen 80;
    server_name _;

    root /srv/quartz/public;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /status {
        alias /srv/quartz/public/status.json;
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
    }
}
```

## Phase 14: Enable Site

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/quartz /etc/nginx/sites-enabled/quartz
sudo nginx -t && sudo systemctl reload nginx
```

## Phase 15: Verify

```bash
curl http://localhost/            # should return 200
curl http://localhost/status      # should return JSON
```

Visit `http://<container-ip>` from desktop.

## Phase 16: DNS

```
wiki.home.arpa → 172.16.12.17
```

In `/etc/hosts` on Akuma as fallback:

```
172.16.12.17 wiki.home.arpa quartz
```

## Phase 17: Update Pipeline

`/srv/quartz/update-wiki.sh` (created by bootstrap):

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /srv/vault
git pull

rsync -av --delete /srv/vault/docs/ /srv/quartz/content/

cd /srv/quartz
npx quartz build
```

Run from the LXC:

```bash
./update-wiki.sh
```

Or run from the host via SSH:

```bash
ssh ken@172.16.12.17 /srv/quartz/update-wiki.sh
```

The host-side wrapper at `~/dotfiles/scripts/update-quartz.sh` does the same.

## Phase 18: Status Endpoint

The nginx config above already serves `/status` from `public/status.json`.
Regenerated after every build by `scripts/quartz/generate-status.sh`:

```json
{
  "status": "ok",
  "time": "2026-06-24T00:15:49+00:00",
  "files": 152,
  "build": { "timestamp": "...", "files": 152 },
  "git": { "commit": "a1b2c3d", "branch": "v5" },
  "vault": { "commit": "e4f5g6h", "branch": "deb" },
  "runtime": { "node": "v22.14.0", "npm": "10.9.2" }
}
```

## Snapshot Points

```bash
pct snapshot 301 node-installed
pct snapshot 301 quartz-installed
pct snapshot 301 nginx-working
pct snapshot 301 first-sync-working
pct snapshot 301 status-endpoint
```

## Directory Layout (final)

```
/srv/
├── vault/           ← git clone, docs/ is the content unit
│   └── docs/
├── quartz/          ← single working instance
│   ├── content/     ← rsync snapshot from vault/docs/
│   ├── public/      ← build output
│   │   ├── index.html
│   │   └── status.json
│   └── update-wiki.sh
└── backups/
```

## Two-Stage Bootstrap

The system is built in two independent stages:

1. **Host level** — `scripts/bootstrap-quartz-lxc.sh`: creates LXC on Proxmox
2. **Container level** — `scripts/bootstrap-quartz-stack.sh`: installs Node, Quartz, nginx, update script

This separation keeps the system reproducible from bare Proxmox.

## Key Constraints

- Canonical docs: `~/dotfiles/docs` (on Akuma, in Git) — never edit generated files
- Quartz content directory is a disposable copy (rsync `--delete` from vault)
- No hardcoded IPs in markdown content
- Container serves wiki, does not initiate connections to host
- Status endpoint makes the container self-observable — AI tooling can check `/status` before triggering rebuilds

## Open Questions

1. **Trigger method** — Manual SSH, git hook auto-publish, or systemd path unit?
2. **DNS** — OPNsense reservation (`172.16.12.17` → `wiki.home.arpa`) or just `/etc/hosts` on Akuma?
3. **Auto-deploy** — Git hook in vault that SSHs into the LXC and runs `update-wiki.sh`?

## Next Evolution

Current: manual `update-wiki.sh` invocation.

Next: **event-driven publishing** — `post-receive` hook auto-syncs + auto-builds + instantly publishes.
