---
tags: [research, runbook, operations, vault-architecture]
status: proposed
source: opencode-session-2026-06-21
---

# Runbook Architecture — Research Note

The current vault is heavily reference-oriented. What's missing is an **operations cookbook** or **runbook library** — reusable command blocks with variable substitution, so six months from now you don't need to remember CT IDs, host-vs-container context, or one-time vs daily ops.

## Proposed Structure

```text
docs/
└── runbooks/
    ├── proxmox/
    │   ├── lxc-lifecycle.md
    │   ├── lxc-cloning.md
    │   ├── snapshots.md
    │   └── ssh-management.md
    │
    ├── quartz/
    │   ├── quartz-install.md
    │   ├── quartz-update.md
    │   └── quartz-rebuild.md
    │
    ├── templates/
    │   ├── new-lxc.md
    │   ├── ai-agent-node.md
    │   ├── wiki-node.md
    │   └── debian-base.md
    │
    └── cheatsheets/
        ├── common-commands.md
        ├── ssh-shortcuts.md
        └── recovery.md
```

## Key Patterns

- **Variables at top** — `CTID=301`, `IP=172.16.1.44` — change one line, not every command
- **Host vs container context** — prefix commands with context marker (`[host]` / `[container]`)
- **One-time vs daily ops** — separate sections for install vs update vs rebuild
- **Agent-friendly index** — `vault/ops/container-index.md` with CTID, IP, purpose, access commands per container

## Container Index Concept

```markdown
# Container Index

## 300
Name: quartz-test
Purpose: Reference container before Quartz install
Status: frozen
Access:
  pct enter 300

## 301
Name: quartz-base
Purpose: Active Quartz development
Status: running
Access:
  pct enter 301
  ssh ken@172.16.1.44
```

## Example: New LXC Template

```markdown
# New LXC

Variables:
  CTID=300
  HOSTNAME=quartz-test
  IP=172.16.1.44

Commands:
  pct enter $CTID
  pct start $CTID
  pct stop $CTID
  pct reboot $CTID
  ssh ken@$IP
  pct snapshot $CTID pre-change
  pct rollback $CTID pre-change
```

## Future Work

- Review all existing docs, extract every command example, convert hardcoded values to variables
- Generate `docs/runbooks/command-library.md` — a personal command catalog
- Identify repeated command sequences and suggest reusable command blocks
- Build an AI-readable operations library that replaces shell-history dependency

## References

- Proposed during 2026-06-21 opencode session after Quartz container setup discussion
