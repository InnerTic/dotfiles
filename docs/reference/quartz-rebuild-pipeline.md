# Quartz One-Command Rebuild Pipeline — Design Spec

Status: **to test** — design captured, not yet implemented.

## Target: `./rebuild-wiki.sh`

A single entry point that safely destroys and recreates the full Quartz LXC from scratch:

```
stop old CT → snapshot (optional) → destroy CT → create CT → install stack → clone vault → build quartz → start nginx → verify health → print URL
```

## Safety Gates

- Confirmation prompt requires typing `REBUILD` before any destructive action
- Optional pre-destroy snapshot for rollback
- Vault is NEVER inside LXC state — Git is the source of truth
- Container is fully disposable

## Three-Script Architecture

```
rebuild-wiki.sh        ← orchestrator (one command entry point)
bootstrap-quartz-lxc.sh       ← Proxmox host: create LXC
bootstrap-quartz-stack.sh     ← inside-container: Node, Quartz, nginx, vault sync
```

### Orchestrator (`rebuild-wiki.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

CTID=301
HOST="quartz-base"

echo "[!] FULL REBUILD STARTING FOR CT $CTID"
echo "[!] This will destroy and recreate the container"

read -p "Type 'REBUILD' to continue: " confirm
if [[ "$confirm" != "REBUILD" ]]; then
  echo "Aborted."
  exit 1
fi

echo "[+] Destroying old container (if exists)"
pct stop $CTID || true
pct destroy $CTID || true

echo "[+] Running LXC bootstrap"
bash ./bootstrap-quartz-lxc.sh

echo "[+] Waiting for container to come up"
sleep 10

echo "[+] Running inside-container bootstrap"
ssh root@<container-ip> 'bash -s' < ./bootstrap-quartz-stack.sh

echo "[+] Done — wiki should be available at http://wiki.home.arpa"
```

### Host-level bootstrap (`bootstrap-quartz-lxc.sh`)

Already exists at `scripts/bootstrap-quartz-lxc.sh` — creates LXC from Ubuntu 24.04 template with DHCP networking. No SSH key injection needed; stack bootstrap runs via `pct enter` or discovered IP.

### Container-level bootstrap (`bootstrap-quartz-stack.sh`)

Already exists at `scripts/bootstrap-quartz-stack.sh` — installs Node 22, clones Quartz, runs `npm install`, creates nginx config, clones vault to `/srv/vault`, rsyncs `docs/` to content, runs first build.

## Key Design Properties

| Property | Why |
|----------|-----|
| Fully reproducible | No hidden state survives container rebuild |
| Vault is external truth | Git repo untouched by destroy |
| Container is disposable | Delete without fear |
| No symlinks | No ELOOP recursion issues |
| Version-controlled infra | Scripts live in `~/dotfiles/scripts/` |

## Next Upgrades (After Tested)

1. **Snapshot-safe rebuild** — `pct snapshot 301 pre-rebuild` before destroy
2. **Git hook auto-trigger** — Push to vault → auto rebuild
3. **Health endpoint check** — Verify `/status` before marking build successful
4. **Makefile interface** — `make rebuild`, `make deploy`, `make backup`
5. **Multi-container scaling** — Same pattern for wiki (301), ai-docs (302), logs (303)

## Mental Model

```
            ┌──────────────┐
            │  Git Vault   │
            └──────┬───────┘
                   │
        rsync + build pipeline
                   │
        ┌──────────▼──────────┐
        │ Quartz LXC (ephemeral)│
        └──────────┬──────────┘
                   │
                Nginx
                   │
        wiki.home.arpa
```

The container is never a source of truth. Git is. The rebuild pipeline is just a cached render.
