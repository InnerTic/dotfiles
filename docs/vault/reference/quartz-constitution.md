# AI Project Constitution: Obsidian Digital Garden Homelab Wiki

## Project Goal

Build a zero-friction documentation and publishing system for a homelab.

The system should have one canonical source of truth and automatically generate a searchable website from it.

The design should prioritize:

- Simplicity
- Portability
- Human maintainability
- Git friendliness
- Linux friendliness

The project should avoid unnecessary automation or complexity.

---

## Core Philosophy

The vault does not know where it lives.

Markdown files should never contain machine-specific addresses.

Content should remain portable between:

- Desktop
- Laptop
- VM
- Homelab server
- Public website

Changing servers should not require editing notes.

---

## Source of Truth

Canonical documentation: `~/dotfiles/docs`

Nothing edits generated files.

Generated files may be destroyed and recreated at any time.

---

## Build Pipeline

```
Canonical docs
    ↓
Quartz content snapshot
    ↓
Quartz build
    ↓
Static website
    ↓
Web server
```

---

## Directory Layout

| Purpose | Path |
|---------|------|
| Canonical | `~/dotfiles/docs` |
| Quartz input | `~/quartz/content` |
| Quartz output | `~/quartz/public` |

Quartz content is a synchronized copy. Quartz public is disposable.

---

## Link Format

Use Obsidian wiki links.

Example: `[[Quartz Setup]]`

Avoid absolute URLs, embedded machine IP addresses, and hardcoded localhost references.

---

## URL Philosophy

Prefer hostnames over IP addresses.

| Preference | Example |
|------------|---------|
| Preferred | `wiki.home.arpa` |
| Acceptable | `vault.home.arpa` |
| Avoid | `172.x.x.x` |

Machine addresses should be infrastructure configuration, not content configuration.

---

## Git Philosophy

Git tracks source documentation. Generated output should not become the canonical source.

Repository should clone cleanly onto another Linux machine.

---

## Operating System

Primary target: Linux

Primary workflow: Desktop editing, local builds, LAN publishing, optional public publishing.

Do not assume Windows compatibility.

---

## Automation Philosophy

- Prefer simple shell scripts.
- Prefer explicit steps.
- Avoid hidden magic.
- Avoid background daemons unless necessary.
- One command should perform one logical task.

---

## AI Working Rules

- Do not redesign the project without justification.
- Do not introduce new frameworks unless they solve a real problem.
- When uncertain, choose the simpler solution.
- Before generating scripts, explain what the script will do.
- After generating scripts, explain where they belong and how to test them.
- Never skip explanations.
- Never combine multiple major project stages into one script unless requested.
- Each stage should be independently testable.
- Stop after each milestone and wait for verification before proceeding.
- Treat existing files as valuable. Avoid destructive operations. Prefer backups.
- Prefer idempotent scripts.
- Document assumptions.

The objective is to create a maintainable homelab knowledge appliance rather than merely deploy a static website.

---

## Task Blocks

See [[quartz-setup]] for current installation state.

### Task Block 1 — Directory Structure

Create the project directory structure. Do not install software. Do not modify existing documentation.

### Task Block 2 — Install Quartz

Install only missing dependencies. Create a standard Quartz installation. Do not copy notes yet.

### Task Block 3 — Sync the Vault

Synchronize canonical documentation (`~/dotfiles/docs`) into Quartz (`~/quartz/content`) using `rsync`. Destination is disposable, source is authoritative.

### Task Block 4 — Build the Wiki

Generate the static site. Verify output. Do not configure a web server yet.

### Task Block 5 — Serve the Site Locally

Choose a lightweight static web server. Support localhost and LAN access. Do not hardcode IP addresses.
