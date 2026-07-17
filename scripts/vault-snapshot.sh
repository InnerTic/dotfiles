#!/usr/bin/env bash
# vault-snapshot — Wrapper around archive-script
#
# Usage:
#   vault-snapshot llama-loader           # archive all scripts in a project
#   vault-snapshot llama-loader/run.sh    # archive single file
#   vault-snapshot --list                 # list available targets

set -euo pipefail

SCRIPTS_SRC="$HOME/dotfiles/scripts"
ARCHIVE="$SCRIPTS_SRC/archive-script.sh"

case "${1:-}" in
  --list)
    echo "Available snapshot targets:"
    find "$SCRIPTS_SRC" -name "*.sh" \
      -not -path "*/llama-loader.old/*" \
      -not -path "*/bootstrap/*" \
      -not -path "*/lxc/*" \
      | sed "s|$SCRIPTS_SRC/||" \
      | sort
    ;;
  *)
    target="${1:-}"
    if [[ -z "$target" ]]; then
      echo "Usage: vault-snapshot <project> [file]"
      echo "       vault-snapshot --list"
      exit 1
    fi

    if [[ -f "$SCRIPTS_SRC/$target" ]]; then
      bash "$ARCHIVE" "$target"
    elif [[ -d "$SCRIPTS_SRC/$target" ]]; then
      echo "Snapshots for $target:"
      find "$SCRIPTS_SRC/$target" -name "*.sh" | sort | while read -r f; do
        rel="${f#$SCRIPTS_SRC/}"
        bash "$ARCHIVE" "$rel"
      done
    else
      echo "Not found: $SCRIPTS_SRC/$target"
      exit 1
    fi
    ;;
esac
