# Context Documents Index

AI reference docs for system rebuild. Files marked **CURRENT** reflect actual system state.
Files marked **HISTORICAL** are kept as reference but contain stale paths/layouts.

## Current (Authoritative)

| File | Description |
|------|-------------|
| **`system-memory.md`** | **START HERE.** Merged AI reference — actual drives, mounts, UUIDs, aliases, GW2, network, rebuild quick-ref. Updated 2026-05-10. |
| `quick-commands.md` | Quick-start commands for all AI tools (llama, Forge, TextGen, OpenClaw, OpenCode) |
| `package-list.txt` | Clean package list for CachyOS reinstall |
| `kde-settings.md` | KDE Plasma backup/restore file list |
| `gw2-multibox-wine-setup.md` | GW2 multi-boxing setup — distilled from FixBot log |
| `rebuild-notes.md` | Latest rebuild notes (in parent dir) |

## Historical (Stale — Reference Only)

| File | Description |
|------|-------------|
| `storage-layout-plan.md` | Original drive layout plan — **drive labels/sizes are wrong** (claimed sda=465GB bulk, actually sda=119GB OS). Actual layout in `system-memory.md`. |
| `implementation-workflow.md` | Original migration workflow — references old paths (`/workspace/...`). Actual state in `system-memory.md`. |
| `system-profile.md` | Original system profile from backup. Some specs OK, but storage info is stale. |
| `ollama-notes.md` | Original Ollama GPU/CPU notes — may have stale paths. |
| `opencode-plugins.md` | Original plugin analysis — paths may be stale. |
| `serena-mcp.md` | Original Serena MCP notes. |

## External References

| Location | Content |
|----------|---------|
| `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` | Full FixBot chat log (5269 lines, 300KB) — GW2 debugging |
| `~/dotfiles/docs/commands.txt` | Full command reference with paths and hardware notes |
| `~/dotfiles/docs/quick-commands.txt` | Condensed quick-reference command cheat sheet |
