# Quartz LXC Deployment — Retrospective

## What It Was

Deploy Quartz v5 digital garden on a Proxmox LXC container (CT 301, `quartz-base`, `172.16.12.17`) to serve the Obsidian vault as a static site with a self-observable `/status` endpoint.

The canonical plan lived in `docs/vault/software/quartz/container-plan.md` — 18 phases covering Node 22 install, Quartz [[setup]], web server config, DNS, update script, and status endpoint.

The LXC was cloned from a gold template (CT 300) built with `scripts/build-gold-lxc.sh` and provisioned with `scripts/lxc-provision.sh`.

## What It Was Supposed To Take

Per the plan:
- 18 sequential phases, each with a copy-paste command block
- Node 22 via NodeSource, `pnpm`, Quartz clone + build, Caddy reverse proxy
- Directory layout: `/srv/vault/` (git repo), `/srv/quartz/` (site), `/srv/quartz-src/` (upstream ref)
- Update pipeline: `rsync -av --delete /srv/vault/ /srv/quartz/content/` + rebuild
- Snapshot after each working phase (`node-installed`, `quartz-installed`, `caddy-working`, `first-sync-working`, `status-endpoint`)

Estimated effort on paper: ~2–3 hours of sequential shell commands.

### Corrections Applied (v3)

The iterative process (v1 plan → v2 nginx/nginx-status.conf → v3 corrections) converged on:

| Issue | Correction |
|-------|-----------|
| Both npm + pnpm | **npm-only** — Quartz v5 is npm-first, pnpm adds drift |
| `cp -a` duplication | **Single clone** at `/srv/quartz` — no `/srv/quartz-src` |
| rsync from vault root | **rsync `docs/` only** — avoids `.git/` and config bleed |
| Caddy + nginx duality | **nginx-only** — LXC already had it, no reason to add Caddy |
| `~/apps/` layout | **`/srv/` layout** — standard for container services |
| No NOPASSWD sudo | **Added Phase 4** — `sudoers.d/ken` in provisioning |
| Missing snapshots | **Phase 0 restored** — snapshot before each working phase |

## What It Really Took

### Phase 0: Bootstrap infrastructure (4–5 hours of earlier sessions)

Before any LXC work, the dotfiles repo needed:

| Task | Effort |
|------|--------|
| Merge `main` → `deb` (13 conflicts) | ~1h |
| Modular bootstrap refactor (lib/, modules/, 6 profiles) | ~2h |
| Container-aware shell provisioning (12-containers.sh) | ~1h |
| GnuPG backup module | ~30m |

### Phase 1–7: Gold template + initial LXC setup (earlier sessions)

These were already done when this session started:
- CT 300 built as gold template
- CT 301 cloned and running
- Node 22 installed
- Quartz cloned at `/home/ken/apps/quartz` (not `/srv/quartz`)
- Quartz built successfully (152 files)

### Phase 8–11: nginx + status endpoint (this session, ~30m)

LXC already had nginx on port 80. We reconfigured it.

**Problems encountered:**
1. nginx root path was wrong: `/home/quartz/apps/quartz/public` instead of `/home/ken/apps/quartz/public` — 500 error on every request
2. Duplicate `+` symlink in `sites-enabled/` caused nginx warning ("conflicting server name")
3. `ken` user needed `sudo` password for config edits (`admin1234`) — no NOPASSWD configured
4. Status JSON template needed real metrics (file count, index size, build time)

**Fixes:**
1. Fixed root path in `/etc/nginx/sites-available/quartz`
2. Removed `+` symlink (both pointed to same file)
3. Added `/status` location block with alias to `status.json`
4. Generated initial `status.json` with live file count (152) and index size (31KB)

### Status endpoint: built proactively (~20m script creation + removal of `+` symlink)

The status endpoint was not in the original [[container-plan]] — it was added as Phase 18 during this work. Three files were created:
- `scripts/quartz/generate-status.sh` — emits `status.json` with build metadata
- `scripts/quartz/nginx-status.conf` — nginx location snippet
- `scripts/update-quartz.sh` — vault pull → rsync → rebuild → status

### Bootstrap scripts created

Two-stage bootstrap system written to match the v3 corrections:

- `scripts/bootstrap-quartz-lxc.sh` — Proxmox host level: creates LXC from template
- `scripts/bootstrap-quartz-stack.sh` — Inside container: Node, Quartz, nginx, update script

These make the deployment **reproducible from bare Proxmox** — destroy and rebuild from scratch.

### Update pipeline corrected

`scripts/update-quartz.sh` now uses `$VAULT_DIR/docs/` as the rsync source (not `$VAULT_DIR/`), matching the v3 layout.

### Snapshots: NOT TAKEN (on the active LXC)

No `pct snapshot 301 <phase>` was executed during deployment. The bootstrap scripts assume this is done as Phase 0 on future deployments.

## Key Lessons

1. **Plan vs reality — paths drift.** The plan said `/srv/quartz` + Caddy; deployment ended up at `~/apps/quartz` + nginx. v3 corrections reconcile the plan to `/srv/` + nginx — what the bootstrap scripts actually produce.

2. **nix-status pattern works.** The `/status` endpoint returned useful JSON on first request after config fix — zero debugging needed. Worth the upfront script cost.

3. **Snapshots are cheap, regret is expensive.** Not taking phase-boundary snapshots means any future breakage requires a full re-clone from gold template. Take the 5 seconds.

4. **sudo access assumptions fail.** The gold template didn't set up NOPASSWD sudo. Every container-admin task hit a password prompt. Fix: add `echo "ken ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ken` during provisioning.

5. **Bootstrap scope creep.** What started as "deploy Quartz on LXC" pulled in a full dotfiles refactor (modular bootstrap, merge resolution, version policy, GPG backup, container detection). The container work was ~30m; the infrastructure work was ~5h.

6. **Status endpoint should include update pipeline status.** The current `status.json` doesn't show when the vault was last synced, making it hard to know if the site is stale. Add a `last_sync` field.
