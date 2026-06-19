# Vault Query Scripts

Minimal retrieval system: Fish CLI frontend + Bash backend. Grep-first, index-aware, no embeddings yet.

## Files

| File | Location | Purpose |
|------|----------|---------|
| `vault-query.fish` | `~/.local/bin/vault-query.fish` | User-facing CLI |
| `vault-query.sh` | `~/.local/bin/vault-query.sh` | Index search + ranking engine |

Both must be executable: `chmod +x ~/.local/bin/vault-query.*`

## `vault-query.fish`

```fish
#!/usr/bin/env fish

set query (string join " " $argv)

if test -z "$query"
    echo "Usage: vault-query <search text>"
    exit 1
end

set VAULT_ROOT "$HOME/vault"
set SCRIPT "$HOME/.local/bin/vault-query.sh"

if not test -f "$SCRIPT"
    echo "Missing backend script: $SCRIPT"
    exit 1
end

bash $SCRIPT $VAULT_ROOT $query
```

## `vault-query.sh`

```bash
#!/usr/bin/env bash

VAULT_ROOT="$1"
QUERY="$2"

if [[ -z "$VAULT_ROOT" || -z "$QUERY" ]]; then
  echo "Usage: vault-query.sh <vault_root> <query>"
  exit 1
fi

CONV_DIR="$VAULT_ROOT/conversations"
KNOW_DIR="$VAULT_ROOT/knowledge"
DEC_DIR="$VAULT_ROOT/decisions"

echo "🔎 Vault Query: $QUERY"
echo "========================================"

score_file() {
  local file="$1"
  local hits
  hits=$(grep -i "$QUERY" "$file" 2>/dev/null | wc -l)
  if [[ $hits -gt 0 ]]; then
    echo "$hits:$file"
  fi
}

TMP=$(mktemp)

for dir in "$DEC_DIR" "$KNOW_DIR" "$CONV_DIR"; do
  if [[ -d "$dir" ]]; then
    find "$dir" -type f -name "*.md" | while read -r file; do
      score_file "$file"
    done
  fi
done >> "$TMP"

sort -t: -k1 -nr "$TMP" | head -n 10 > "${TMP}_sorted"

echo ""
echo "Top matches:"
echo "----------------------------------------"

while IFS=: read -r score file; do
  echo ""
  echo "[$score] $file"
  echo "----------------------------------------"
  grep -i -n "$QUERY" "$file" | head -n 3 | while read -r line; do
    echo "  $line"
  done
done < "${TMP}_sorted"

rm -f "$TMP" "${TMP}_sorted"
```

## Behavior

```
$ vault-query gpu_mode persistence
🔎 Vault Query: gpu_mode persistence
========================================

Top matches:
----------------------------------------

[3] /home/ken/vault/decisions/2026-06-19-np-state-format.md
----------------------------------------
  line 12: gpu_mode never persisted to state
  line 15: NP_ARG stored with -np prefix, causing double-prefix
  line 20: fix: added gpu_mode to profile state
```

## Upgrade Path

| Phase | Improvement |
|-------|-------------|
| Now | grep-first, no dependencies |
| Soon | `--decision-only`, `--knowledge-only`, `--conversation-only` flags |
| Later | index JSON lookup instead of raw grep |
| Future | ripgrep hybrid (10-50x faster) |
| Later | embeddings for semantic search |

## llama-loader Integration

```bash
vault-query gpu_mode persistence | llama-loader
vault-query gpu_mode persistence | planner.sh
```

## Next Components (Not Yet Built)

- `vault-indexer.sh` — builds JSON indexes automatically
- Agent context builder — turns results into LLM prompt blocks
- ripgrep-based version — 10-50x speedup over grep
