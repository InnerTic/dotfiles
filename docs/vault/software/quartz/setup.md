# Quartz Digital Garden Setup

Quartz v5.0.0 — static site generator for the Obsidian vault.

## Installation

```bash
cd ~
git clone https://github.com/jackyzha0/quartz.git
cd ~/quartz
npm install
```

## Configuration

```bash
# Create config from default
cp quartz.config.default.yaml quartz.config.yaml
# Edit baseUrl, theme, plugins as needed
```

## Content Symlink

```bash
# Link your Obsidian vault
ln -sf ~/dotfiles/docs ~/quartz/content
```

## Plugin Installation

```bash
# Install all plugins from lockfile
npx quartz plugin install
```

## Build

```bash
npx quartz build
# Output goes to public/
```

Serve locally:

```bash
npx quartz build --serve
```

## Maintenance Commands

| Command | Purpose |
|---------|---------|
| `npx quartz build` | Build static site |
| `npx quartz build --serve` | Build + dev server with live reload |
| `npx quartz plugin install` | Install/update plugins from lockfile |
| `npx quartz plugin list` | List installed plugins |
| `npx quartz upgrade` | Upgrade Quartz to latest version |

## Known Issues

**ELOOP on build:** Content symlink was circular. Fix:

```bash
# Check if docs is a symlink to itself
ls -la ~/dotfiles/docs
# If broken, restore from git and re-link
rm ~/dotfiles/docs && git checkout HEAD -- docs
```

**Plugins not found on build:** Run plugin install first:

```bash
npx quartz plugin install
```
