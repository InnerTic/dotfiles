#!/usr/bin/env bash
# archive-script — Archive a dotfiles script as restorable markdown
#
# Usage:
#   archive-script dotfiles/scripts/llama-loader/core/dialects/llama.cpp.sh
#   archive-script --all
#
# Creates:
#   vault/script-reference/<path>.md
#
# Each archive includes YAML frontmatter (source, checksum) and a restore footer.

set -euo pipefail

VAULT="$HOME/vault"
SCRIPTS_SRC="$HOME/dotfiles/scripts"
SCRIPT_REF="$VAULT/script-reference"

archive_one() {
  local src_path="$1"
  local full_path="$SCRIPTS_SRC/$src_path"

  if [[ ! -f "$full_path" ]]; then
    echo "Not found: $full_path"
    return 1
  fi

  local name
  name=$(basename "$src_path")
  local rel_md="${src_path%.sh}.md"
  local out_path="$SCRIPT_REF/$rel_md"
  local checksum
  checksum=$(sha256sum "$full_path" | cut -d' ' -f1)

  mkdir -p "$(dirname "$out_path")"

  cat > "$out_path" <<EOF
---
source: dotfiles/scripts/$src_path
restorable: true
checksum: $checksum
last_verified: $(date +%Y-%m-%d)
---

# $name

\`\`\`bash
$(cat "$full_path")
\`\`\`

## Restore

\`\`\`bash
vault-restore ${name%.sh}
\`\`\`
EOF

  echo "Archived: $rel_md"
}

case "${1:-}" in
  --all)
    echo "Archiving all scripts..."
    find "$SCRIPTS_SRC" -name "*.sh" \
      -not -path "*/llama-loader.old/*" \
      -not -path "*/bootstrap/*" \
      -not -path "*/lxc/*" \
      | sed "s|$SCRIPTS_SRC/||" \
      | sort \
      | while read -r f; do
        archive_one "$f"
      done
    ;;
  *)
    if [[ -z "${1:-}" ]]; then
      echo "Usage: archive-script <relative-path>"
      echo "       archive-script --all"
      exit 1
    fi
    archive_one "$1"
    ;;
esac
