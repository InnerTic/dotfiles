# Quartz Digital Garden Setup

Quartz v5.0.0 — static site generator for the Obsidian vault.

**Requires:** Node >=22, npm >=10.9.2. Debian 12 ships Node 18 — must use NodeSource.

## Verify First

```bash
node -v
npm -v
```

If Node <22, remove distro packages and install from NodeSource:

```bash
sudo apt remove -y nodejs npm
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v && npm -v
```

## Installation

```bash
cd /srv
git clone https://github.com/jackyzha0/quartz.git quartz-src
cd quartz-src
npm ci
```

## Configuration

```bash
cp quartz.config.default.yaml quartz.config.yaml
# Edit baseUrl, theme, plugins as needed
```

## Content

```bash
ln -sf /srv/vault/docs/ /srv/quartz/content
# or rsync for isolated copy:
# rsync -av --delete /srv/vault/ /srv/quartz/content/
```

## Build

```bash
npx quartz build
npx quartz build --serve    # dev server with live reload
```

## Production

Deploy to LXC container (see [container-plan.md](./container-plan.md)) with Caddy reverse proxy at `wiki.home.arpa`.

## Known Issues

- **ELOOP on build:** Content symlink was circular — restore from git and re-link
- **[[plugins]] not found:** Run `npx quartz plugin install` before building
- **npm ci vs npm install:** Use `npm ci` for reproducible builds from lockfile
