# Migration Checkpoint

**Session:** 2026-06-21
**Last completed phase:** Phase 1 (plan complete, dry run only)
**Next phase:** Phase 2 — Repo Separation Setup

## Completed

- Phase 0: Inventory & Mapping → `migration/report-phase0-inventory.md`
- Phase 1: Dry Run Plan → `migration/phase1-plan.md`

## To Resume

1. Run `cat migration/phase1-plan.md` to review the plan
2. Proceed to Phase 2: create three git repos (vault, dotfiles, infra)
3. Phase 3: safe COPY migration (never delete)
4. Phase 4: validation
5. Phase 5: reference rewrites
6. Phase 6: final cutover

## Key Decisions to Date

- VAULT (178 files): all `docs/`, `CHANGELOG.*`, `KEY_LOCATIONS.txt`
- DOTFILES (35 files): `shell/`, `ssh/`, `git/`, bootstrap, `AGENTS.md`, `README.md`, `.gitignore`, `scripts/bootstrap/`, `scripts/link-workspace.sh`, `scripts/test-cleanup-backups.sh`, `scripts/toggle-p40.example.yaml`
- INFRA (37 files): `scripts/llama-loader/`, `scripts/lxc/`, Proxmox scripts, service scripts, system scripts
- Migration order: A→B→C→D (vault first, dotfiles second, infra third, fixes last)
- Rule: always COPY first, never delete, log everything
