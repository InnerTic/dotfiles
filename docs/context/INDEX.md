# Context Documents Index

AI reference docs for system rebuild. Files marked **CURRENT** reflect actual system state.
Files marked **HISTORICAL** are kept as reference but contain stale paths/layouts.

## Current (Authoritative)

| File | Description |
|------|-------------|
| **`system-memory.md`** | **START HERE.** Merged AI reference — actual drives, mounts, UUIDs, aliases, GW2, network, rebuild quick-ref. Updated 2026-05-10. |
| `quick-commands.md` | Quick-start commands for all AI tools (llama, Forge, TextGen, OpenClaw, OpenCode) |
| `free-models.md` | Free online model reference (OpenCode Zen + OpenRouter). Includes context sizes, capabilities, best-use notes. Updated 2026-05-13. |
| `free-providers.md` | Free LLM API providers beyond OpenRouter/Zen. Registration info, limits, how to add to opencode config for redundancy. Updated 2026-05-13. |
| `package-list.txt` | Clean package list for CachyOS reinstall |
| `kde-settings.md` | KDE Plasma backup/restore file list |
| `kde-workarounds.md` | Tracked KDE bugs with workarounds & review-by dates |
| `dolphinrc` | Reference dolphinrc config (ShowHiddenFiles, Details view) |
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
| `~/dotfiles/docs/system_backup/` | Full backup/restore reference directory |
| `~/dotfiles/docs/commands.txt` | Full command reference with paths and hardware notes |
| `~/dotfiles/docs/quick-commands.txt` | Condensed quick-reference command cheat sheet |
| `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` | Full FixBot chat log (5269 lines, 300KB) — GW2 debugging |
