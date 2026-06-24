# Quartz Container Plan — v2

Move Quartz from host into a dedicated LXC container.

## Target Architecture

Obsidian Vault (desktop)
        │
        ▼
Git Repository (Akuma: ~/dotfiles)
        │
        ▼ ssh rsync
Quartz Container (301)
    /home/ken/apps/quartz    ← Quartz site (config + content/ → public/)
        │
        ▼ nginx
        │
        ▼
http://172.16.12.17

## Container

| Property | Value |
|----------|-------|
| LXC ID | 301 |
| Hostname | quartz-base (existing, running) |
| IP | `172.16.12.17` |
| User | `ken` (present, sudo) |
| Shell | bash |

## Phase 0: Snapshot First

```bash
pct snapshot 301 pre-quartz-install
pct listsnapshot 301
```

## Phase 1: Enter Container

```bash
ssh ken@172.16.12.17
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

## Phase 4: NOPASSWD sudo (skip if already done)

```bash
echo "ken ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ken
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
mkdir -p ~/apps
cd ~/apps
git clone https://github.com/jackyzha0/quartz.git quartz
cd quartz
pnpm install
pnpm quartz --help
```

## Phase 8: Configure Quartz

Edit `~/apps/quartz/quartz.config.yaml` — set base URL, theme colors, enable/disable plugins as desired.

## Phase 9: Populate Content

Either rsync from the host or copy existing vault content:

```bash
# from host:
rsync -avz ~/dotfiles/docs/ ken@172.16.12.17:~/apps/quartz/content/

# or from within the LXC if content was placed previously:
ls ~/apps/quartz/content/
```

## Phase 10: Build

```bash
cd ~/apps/quartz
pnpm quartz build
ls public/index.html
```

## Phase 11: Test Locally

```bash
cd ~/apps/quartz
pnpm quartz serve
```

Visit `http://172.16.12.17:8080` from desktop. Ctrl+C to stop.

## Phase 12: Install & Configure nginx

```bash
sudo apt install -y nginx
```

Create `/etc/nginx/sites-available/quartz`:

```nginx
server {
    listen 80;
    server_name _;

    root /home/ken/apps/quartz/public;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /status {
        alias /home/ken/apps/quartz/public/status.json;
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
    }
}
```

## Phase 13: Enable Site

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/quartz /etc/nginx/sites-enabled/quartz
sudo nginx -t && sudo systemctl reload nginx
```

## Phase 14: Verify

Visit `http://172.16.12.17` from desktop.

## Phase 15: DNS

```
wiki.home.arpa → 172.16.12.17
```

In `/etc/hosts` on Akuma as fallback:

```
172.16.12.17 wiki.home.arpa quartz
```

## Phase 16: Update Pipeline

From the host (Akuma), push vault content and trigger rebuild:

```bash
rsync -avz --delete ~/dotfiles/docs/ ken@172.16.12.17:~/apps/quartz/content/
ssh ken@172.16.12.17 "cd ~/apps/quartz && pnpm quartz build"
```

The host-side script at `~/dotfiles/scripts/update-quartz.sh` wraps this + status generation.

## Phase 17: Status Endpoint (built-in)

The nginx config above already serves `/status` from `public/status.json`.
Regenerated after every build by `scripts/quartz/generate-status.sh` (run inside the LXC):

```json
{
  "status": "ok",
  "service": "quartz",
  "version": "5.x",
  "build_time": "2026-06-24T00:15:49Z",
  "vault_source": "dotfiles",
  "content_files": 152,
  "index_size_bytes": 31965
}
```

Test:

```bash
curl http://localhost/status
```

## Snapshot Points

```bash
pct snapshot 301 node-installed
pct snapshot 301 quartz-installed
pct snapshot 301 nginx-working
pct snapshot 301 first-sync-working
pct snapshot 301 status-endpoint
```

## Key Constraints

- Canonical docs: `~/dotfiles/docs` (on Akuma) — never edit generated files
- Quartz content dir is a disposable copy (rsync --delete from host)
- No hardcoded IPs in markdown content
- Container serves wiki, does not initiate connections to host
- Status endpoint makes the container self-observable — AI tooling can check `/status` before triggering rebuilds

## Open Questions

1. **Trigger method** — Manual rsync+ssh from Akuma, or automate via git hook / systemd path unit?
2. **DNS** — OPNsense reservation (`172.16.12.17` → `wiki.home.arpa`) or just `/etc/hosts` on Akuma?
3. **Push deploy** — Host-side script to rsync content + SSH trigger build (current), or let the container pull from git?
