# Context Documents Index

AI reference docs for system rebuild. Files marked **CURRENT** reflect actual system state.
Files marked **HISTORICAL** are kept as reference but contain stale paths/layouts.

## Current (Authoritative)

| File | Description |
|------|-------------|
| **[[system-memory]]** | **START HERE.** Merged AI reference — actual drives, mounts, UUIDs, aliases, GW2, network, rebuild quick-ref. Updated 2026-05-10. |
| [[quick-commands]] | Quick-start commands for all AI tools (llama, Forge, TextGen, OpenClaw, OpenCode) |
| [[free-models]] | Free online model reference (OpenCode Zen + OpenRouter). Includes context sizes, capabilities, best-use notes. Updated 2026-05-13. |
| [[free-providers]] | Free LLM API providers beyond OpenRouter/Zen. Registration info, limits, how to add to opencode config for redundancy. Updated 2026-05-13. |
| `package-list.txt` | Clean package list for CachyOS reinstall |
| [[kde-settings]] | KDE Plasma backup/restore file list |
| [[kde-workarounds]] | Tracked KDE bugs with workarounds & review-by dates |
| `dolphinrc` | Reference dolphinrc config (ShowHiddenFiles, Details view) |
| [[gaming/gw2-multibox-wine-setup]] | GW2 multi-boxing setup — distilled from FixBot log |
| [[rebuild/rebuild-notes]] | Latest rebuild notes (in parent dir) |

## Historical (Stale — Reference Only)

| File | Description |
|------|-------------|
| [[storage-layout-plan]] | Original drive layout plan — **drive labels/sizes are wrong** (claimed sda=465GB bulk, actually sda=119GB OS). Actual layout in [[system-memory]]. |
| [[implementation-workflow]] | Original migration workflow — references old paths (`/workspace/...`). Actual state in [[system-memory]]. |
| [[system-profile]] | Original system profile from backup. Some specs OK, but storage info is stale. |
| [[ollama-notes]] | Original Ollama GPU/CPU notes — may have stale paths. |
| [[opencode-plugins]] | Original plugin analysis — paths may be stale. |
| [[serena-mcp]] | Original Serena MCP notes. |

## External References

| Location | Content |
|----------|---------|
| `system_backup/` | Full backup/restore reference directory |
| `reference/commands.txt` | Full command reference with paths and hardware notes |
| `reference/quick-commands.txt` | Condensed quick-reference command cheat sheet |
| `/mnt/workspace/fixbot.ifixit.comchatc4c528.txt` | Full FixBot chat log (5269 lines, 300KB) — GW2 debugging |
