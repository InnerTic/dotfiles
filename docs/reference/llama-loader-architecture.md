# llama-loader — Modular Architecture

**Location:** `~/dotfiles/scripts/llama-loader/`
**Entry:** `llama-loader.sh` (routed via `test-llma-loader` alias)
**Old version:** `~/dotfiles/scripts/llama-loader.old` (via `llama-loader` / `llm` alias)

## Design

BIOS-style stateful GPU inference launcher for llama.cpp.  
Layered pipeline — each script has one responsibility.

```
ENTRY → MODE ROUTER → CONFIG BUILDER → INTROSPECTION → SNAPSHOT → EXEC
```

## File Structure

```
llama-loader/
├── llama-loader.sh          # Entry: shows menu, routes to mode
├── lib/common.sh            # Shared: json helpers, snapshot, decision, save
├── core/run.sh              # Execution: builds cmd, saves state, exec's llama-server
├── modes/
│   ├── last.sh              # Reload last successful config
│   ├── factory.sh           # Hardcoded safe baseline (ctx=8192, split=30/70)
│   ├── preset-router.sh     # Select immutable preset
│   └── custom.sh            # Interactive builder pipeline
├── presets/
│   ├── 1-small.sh           # Fast / low VRAM
│   ├── 2-balanced.sh        # General purpose
│   ├── 3-long-context.sh    # Max context, P40-heavy
│   └── 4-rag-server.sh      # Batch embedding host
├── builder/
│   ├── context.sh           # Context size selection
│   ├── gpu.sh               # GPU mode + split ratio
│   ├── concurrency.sh       # NP + NGL
│   └── network.sh           # Port selection
├── introspect/
│   └── evaluate.sh          # Feasibility check (advisory only)
└── state/
    ├── state.json           # Global last config
    └── models/              # Per-model profiles
```

## Memory Hierarchy

Resolved in this order (first non-empty wins):

1. Per-model last config (`state/models/<model>.json`)
2. Global last config (`state/state.json`)
3. Factory default

## State

- Runtime state stored in `~/.config/llama-loader/` (XDG-compliant)
- Written **only after successful launch** — failed launches never overwrite
- Two levels: global (`state.json`) and per-model (`models/<model>.json`)

## Modes

| Mode | Source | Description |
|------|--------|-------------|
| [1] Last used | `state.json` | Quick re-launch with same settings |
| [2] Factory | hardcoded | Safe baseline, no state dependency |
| [3] Presets | `presets/*.sh` | Immutable configs for common scenarios |
| [4] Custom | builder modules | Full interactive configuration |

## Dual-GPU Config

- **RTX 3060** (GPU 0, 12GB) — fast compute, smaller VRAM
- **Tesla P40** (GPU 1, 24GB) — bulk VRAM
- Factory split: 30/70 (balanced)
- Long context split: 10/90 (P40-heavy)
- Dual GPU split: 20/80 (P40-weighted)
