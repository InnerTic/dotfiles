---
tags: [project, scripts, automation]
aliases: [meta-scripts, script-orchestrator]
status: planned
updated: 2026-06-19
---

# Meta Script Project — Modular Script Orchestrator

Split standalone scripts into modular units, each doing one thing, with a meta script that calls them by name.

## Architecture

```
meta-scripts/
├── meta.sh              ← entry point: meta.sh <module> [args]
├── modules/
│   ├── bridge-setup/    ← vm-bridge-setup broken into sub-steps
│   │   ├── clean.sh     — delete old bridge profiles
│   │   ├── create.sh    — create br0
│   │   ├── attach.sh    — attach NIC as bridge-slave
│   │   └── verify.sh    — check state
│   ├── gpu-profile/     ← toggle-p40.sh modularized
│   ├── llama/           ← llama-loader, start, kill
│   └── system/          ← healthcheck, mounts, fstab
└── lib/
    ├── log.sh           — uniform echo/logging
    ├── confirm.sh       — y/n prompt helper
    └── require.sh       — dependency checker
```

## Design Principles

- Each module is a standalone executable (no sourcing required)
- `meta.sh` detects the module, runs it, passes through args
- Shared helpers in `lib/` sourced by modules
- All modules idempotent — safe to re-run
- `meta.sh list` shows available modules
- `meta.sh `module> --help` per-module help

## Integrations Needed

- `vm-bridge-setup.sh` / `.fish` — split into `bridge-setup/` modules
- `toggle-p40.sh` — split by action (vfio-bind, vfio-unbind, pciegen3, dpm)
- `healthcheck.sh` — split by check (gpu, disk, services, network)
- `llama-loader` — modularize model selection, server start/stop

## Related

- [[scripts/README]] — Existing scripts in vault
- [[software/kvm-bridge-networking]] — Bridge reference
