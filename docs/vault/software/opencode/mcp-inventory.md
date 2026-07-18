---
title: MCP Server Inventory
tags:
  - opencode
  - mcp
  - reference
---

# MCP Server Inventory

All configured MCP servers in `~/.config/opencode/opencode.jsonc`, what they do, and why they're worth having.

## Core Tools

| MCP | What it does | Why you want it |
|-----|-------------|-----------------|
| `sequential-thinking` | Forces step-by-step structured reasoning via thought sequences | Prevents LLM from jumping to conclusions. Saves tokens by eliminating wasted back-and-forth. Especially valuable with smaller local models that tend to rush. |
| `memory` | Knowledge graph-based persistent memory across sessions | Remembers project context, decisions, and preferences between OpenCode sessions. No more re-explaining the vault layout or drive structure. |
| `filesystem` | Secure file operations with configurable access (find, read, write, search) | Efficient file ops without shell grep. Finds files by name/pattern/type without spawning bash. |
| `fetch` | HTTP requests, WebSocket, browser automation | Grabs web content cleanly without HTML bloat in context. |
| `git` | Git operations (log, diff, blame, status) | Structured git commands instead of parsing raw git output. Saves context on every git operation. |
| `pdf` | PDF text extraction | Clean text from PDFs without toolchain. |
| `time` | Timezone-aware current time | Prevents LLM date errors in session logging and journal entries. |

## Search & Web

| MCP | What it does | Why you want it |
|-----|-------------|-----------------|
| `searxng` | Local metasearch via 172.16.12.16:8888 | Private, self-hosted web search. No API costs, no tracking. |
| `opencode` | 80 tools bridging MCP clients to OpenCode headless API | Lets OpenCode spawn child sessions for parallel work. Fire-and-forget translation book processing while continuing to work. |

## Translation Pipeline

| MCP | What it does | Why you want it |
|-----|-------------|-----------------|
| `xcomet` | Translation quality evaluation (0-1 score, error detection) | Automated QC for the 7-book pipeline. Scores translations, flags errors by severity. Runs locally on GPUs. |
| `getlinnk` | Document translation via Linnk API | Cloud translation for books that need a different engine. |
| `general-translation` | General Translation MCP server | Alternative translation provider for the pipeline. |
| `deepl` | DeepL API translation | Premium JP→EN translation. Needs `DEEPL_AUTH_KEY`. (Not currently configured — premium service.) |

## File & Utility

| MCP | What it does | Why you want it |
|-----|-------------|-----------------|
| `filecommander` | 46 tools: OCR, ZIP, encoding fix, duplicate detection, JSON repair, async search | Directly useful for the translation pipeline — fixes encoding issues in raw .htm files, detects duplicates, OCRs scanned pages. |
| `drawio` | Generate diagrams from prompts | Creates architecture diagrams for vault docs without manual drawing. |

## API Keys & Config

| Service | Key/Config | Location |
|---------|-----------|----------|
| SearXNG | `SEARXNG_URL=http://127.0.0.1:8888` | Config |
| xCOMET | Venv at `/mnt/workspace/xcomet-venv`, model `wmt22-comet-da` | Config + cached model |
| HuggingFace | HF user token | `/mnt/data/hf.txt` |
| DeepL | Needs `DEEPL_AUTH_KEY` | Not configured |
| getlinnk/general-translation | May need API keys | Not configured |

## LSP Servers (Native, not via config)

| Language | Server | Package |
|----------|--------|---------|
| Python | `pylsp` | `python-lsp-server` (pacman) |
| Bash | `bash-language-server` | `bash-language-server` (npm) |

> **Note**: LSP is handled by OpenCode natively. Do NOT add an `lsp` block to `opencode.jsonc` — it breaks OpenCode on startup.
