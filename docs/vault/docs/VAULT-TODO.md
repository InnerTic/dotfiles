# Vault & Quartz — To-Do List

**Status:** Vault content restored (149 files), Quartz LXC deployed, wiki live at 172.16.12.17.  
**Branch:** `deb` (mirror), `main` (CachyOS docs)

---

## Phase 1 — Make it Work (In Progress)

- [x] Get Quartz running on LXC (nginx, /status, try_files $uri $uri.html)
- [x] Restore old vault content (149 files from 8bd2b5f)
- [x] Create proper root index at content/index.md
- [x] Disable blank Graph View
- [x] Add both regular + raw [[changelog]] with wiki-links
- [ ] Fix broken wiki-links across vault (use hyalo auto --apply)
- [ ] Add `title` frontmatter to all .md files (kb-lint flagged 7)
- [ ] Create hub pages (systems.md, projects.md, runbooks.md)
- [ ] Choose theme/customizations
- [ ] Verify rebuild from update-quartz.sh end-to-end

## Phase 2 — Make it Reproducible

- [ ] Destroy and rebuild LXC from scratch at least once
- [ ] Pipeline: `new LXC → bootstrap → restore vault → quartz build → site works`
- [ ] No manual fixes required after rebuild

## Phase 3 — Freeze a Template

- [ ] Create `templates/quartz-lxc/` with:
  - Container settings (CTID, template, resources)
  - Packages list
  - Node version spec
  - Quartz version pin
  - nginx config (sites-available)
  - systemd service units
  - Deployment scripts
  - Backup/restore procedure
- [ ] Template describes **infrastructure only**, not vault data
- [ ] Vault remains the source of truth

## Phase 4 — End State

- [ ] Losing the container = minor inconvenience
- [ ] One-command rebuild from bare Proxmox
- [ ] Container is cattle, vault is the asset

---

## Stretch (When Phases 1-4 Are Solid)

- [ ] OPNsense DNS reservation (172.16.12.17 → wiki.home.arpa)
- [ ] Snapshot LXC 301 at working state
- [ ] `docs/vault/system/drives-and-mounts.md`  
  Extract storage layout from [[rebuild-notes]]
  - UUID table for all 5 [[drives-and-mounts]]
  - [[drives-and-mounts]] entries + explanations
  - When to use which drive
  - Bind mount strategy

- [ ] `docs/vault/software/dev-setup.md`  
  Consolidate Python/Git/Shell setup
  - Python venv best practices
  - Git config
  - Shell config inheritance
  - Reference bootstrap.sh

- [ ] `docs/vault/reference/faq.md`  
  Common questions:
  - "Where do my models go?"
  - "How do I switch models?"
  - "Why does workspace exist?"
  - "What persists after OS wipe?"

---

- [ ] **Create `vault-query.fish`** — front CLI  
  `~/.local/bin/vault-query.fish`  
  Fish wrapper that passes query to backend. Takes search text, calls `vault-query.sh`.

- [ ] **Create `vault-query.sh`** — backend engine  
  `~/.local/bin/vault-query.sh`  
  Searches `conversations/`, `knowledge/`, `decisions/` directories. Scores by match count, returns ranked results with context snippets.

- [ ] **Add `--decision-only`, `--knowledge-only`, `--conversation-only` flags**  
  Filter by layer for targeted retrieval.

- [ ] **Upgrade scoring to index JSON lookup**  
  Replace raw grep with structured index metadata. Reserve for after index format is populated.

---

## Medium Priority (Next Week)

- [ ] **Split `known-issues.md` → two files:**
  - `reference/bugs-and-workarounds.md` (temporary fixes, KDE/protontricks)
  - `reference/faq.md` (permanent questions)

- [ ] **`docs/vault/map.md`**  
  Visual [[map]] showing folder structure and navigation paths

- [ ] **Add front matter tags to ALL files:**
  ```markdown
  ---
  tags: [setup, persistence, core]
  aliases: [workspace-link, symlink]
  updated: 2026-06-15
  ---
  ```

- [ ] **`docs/vault/changelog.md`**  
  Track vault structure [[changelog]]:
  - What moved where
  - Why (organization rationale)
  - When

- [ ] **`docs/vault/.gitignore`**  
  Exclude Obsidian metadata from git:
  ```
  .obsidian/workspace.json
  .obsidian/app.json.bak
  .obsidian/plugins/*/data.json
  .DS_Store
  ```

---

## Polish (Nice-to-Have)

- [ ] **`docs/vault/README.md`** for GitHub viewers  
  "This is best viewed in Obsidian. [[QUICK-START]]."

- [ ] **Getting-started index**  
  Entry point explaining vault organization

- [ ] **Add "See Also" sections** to key docs  
  Instead of buried wikilinks

- [ ] **Create Obsidian snippets** for custom styling  
  (if you want custom CSS)

---

## Maintenance (Monthly)

- [ ] Review & update commands when aliases change
- [ ] Add new issues to [[reference/bugs-and-workarounds]] as you find them
- [ ] Archive resolved workarounds (move to permanent sections)
- [ ] Update [[glossary]] with new [[glossary]]

---

## Testing Checklist

- [ ] Open vault in Obsidian
- [ ] Verify graph view shows connections
- [ ] Test all wikilinks resolve
- [ ] Search for 3 random [[glossary]] (should find them)
- [ ] Check that [[QUICK-START]] links work
- [ ] Verify [[glossary]] is comprehensive

---

## Files Created This Session

✅ `docs/vault/QUICK-START.md` — [[QUICK-START]] [[QUICK-START]] guide  
✅ `docs/vault/reference/glossary.md` — [[glossary]] & [[glossary]]  
✅ `docs/vault/software/ai-tools/commands.md` — AI command reference  
✅ `docs/vault/docs/VAULT-TODO.md` — This file

## Completed

✅ Quartz LXC deployed (two-stage bootstrap, nginx, /status endpoint)  
✅ Vault content restored (149 files recovered from git history)  
✅ Wiki-links auto-linked via hyalo  
✅ Modular bootstrap system (lib/, modules/, 6 wrappers)  
✅ Container-aware shell module  
✅ GnuPG backup system  
✅ Version requirements policy document  
✅ Merge main → deb (13 conflicts resolved)  
✅ Root index created at content/index.md  
✅ Graph view disabled  
✅ [[changelog]] split into regular + raw (with wiki-links)  
✅ Flat docs/reference added alongside restored vault  
✅ **`docs/vault/scripts/`** — All scripts migrated into vault  
✅ **`docs/vault/scripts/fastfetch.md`** — [[fastfetch]] config in vault  
✅ **`docs/vault/scripts/README.md`** — Script index with wikilinks

---

## Notes for Next Session

- **[[rebuild-notes]].md still in `/docs/`** — It should stay there (original reference), but content gets redistributed:
  - Storage layout → `system/drives-and-mounts.md`
  - Rebuild steps → `getting-started/os-rebuild-checklist.md`
  - System patches → `reference/bugs-and-workarounds.md`

- **Commands.txt still in `/docs/`** — Split across vault:
  - AI commands → `software/ai-tools/commands.md` ✅
  - System commands → `reference/commands-system.md` (TODO)
  - Network IPs → `system/network.md` (TODO)

- **Original vault files can stay** — Or move entirely to vault/ folder. Current approach: canonical versions live in vault/, originals stay as backups.
