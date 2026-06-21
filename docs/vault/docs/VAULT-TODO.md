# Vault Restructure — To-Do List

**Branch:** `vault-restructure`  
**Status:** Core structure complete. Remaining tasks:

---

## High Priority (Do Next Session)

- [ ] **`docs/vault/system/drives-and-mounts.md`**  
  Extract storage layout from rebuild-notes.md
  - UUID table for all 5 drives
  - fstab entries + explanations
  - When to use which drive
  - Bind mount strategy

- [ ] **`docs/vault/software/dev-setup.md`**  
  Consolidate Python/Git/Shell setup
  - Python venv best practices
  - Git config (from dotfiles)
  - Shell config inheritance
  - Reference bootstrap.sh

- [ ] **`docs/vault/reference/faq.md`**  
  Common questions:
  - "Where do my models go?"
  - "How do I switch models?"
  - "Why does workspace exist?"
  - "What persists after OS wipe?"

---

## High Priority — Vault Query System (Next Session)

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
  Visual sitemap showing folder structure and navigation paths

- [ ] **Add front matter tags to ALL files:**
  ```markdown
  ---
  tags: [setup, persistence, core]
  aliases: [workspace-link, symlink]
  updated: 2026-06-15
  ---
  ```

- [ ] **`docs/vault/changelog.md`**  
  Track vault structure changes:
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
- [ ] Update glossary with new terms

---

## Testing Checklist

- [ ] Open vault in Obsidian
- [ ] Verify graph view shows connections
- [ ] Test all wikilinks resolve
- [ ] Search for 3 random terms (should find them)
- [ ] Check that QUICK-START links work
- [ ] Verify glossary is comprehensive

---

## Files Created This Session

✅ `docs/vault/QUICK-START.md` — Emergency recovery guide  
✅ `docs/vault/reference/glossary.md` — Definitions & abbreviations  
✅ `docs/vault/software/ai-tools/commands.md` — AI command reference  
✅ `docs/vault/docs/VAULT-TODO.md` — This file

## Completed (Previous Sessions)

✅ **`docs/vault/scripts/`** — All scripts migrated from `~/subjects/` and `dotfiles/scripts/` into vault with per-file `.md` views for Obsidian  
✅ **`docs/vault/scripts/fastfetch.md`** — Fastfetch config in vault  
✅ **`docs/vault/scripts/README.md`** — Script index with categorized tables and wikilink entries

---

## Notes for Next Session

- **Rebuild-notes.md still in `/docs/`** — It should stay there (original reference), but content gets redistributed:
  - Storage layout → `system/drives-and-mounts.md`
  - Rebuild steps → `getting-started/os-rebuild-checklist.md`
  - System patches → `reference/bugs-and-workarounds.md`

- **Commands.txt still in `/docs/`** — Split across vault:
  - AI commands → `software/ai-tools/commands.md` ✅
  - System commands → `reference/commands-system.md` (TODO)
  - Network IPs → `system/network.md` (TODO)

- **Original vault files can stay** — Or move entirely to vault/ folder. Current approach: canonical versions live in vault/, originals stay as backups.
