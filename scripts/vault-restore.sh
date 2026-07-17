#!/usr/bin/env bash
# vault-restore — Restore a script from vault/script-reference/
#
# Usage:
#   vault-restore llama.cpp          # search by filename, restore
#   vault-restore path/to/file.sh    # restore exact path
#   vault-restore --list             # list all restorable scripts
#   vault-restore --status           # verify checksums of all archives

set -euo pipefail

VAULT="$HOME/vault"
SCRIPT_REF="$VAULT/script-reference"
DOTFILES_SRC="$HOME/dotfiles/scripts"

extract_checksum() {
  local md_file="$1"
  sed -n '/^checksum:/ { s/^checksum: *//p; q; }' "$md_file" | tr -d ' '
}

extract_source() {
  local md_file="$1"
  sed -n '/^source:/ { s/^source: *//p; q; }' "$md_file" | tr -d ' '
}

extract_code_block() {
  local md_file="$1"
  awk '
    /^```bash$/ { in_block=1; next }
    /^```$/ && in_block { in_block=0; next }
    in_block { print }
  ' "$md_file"
}

find_archive() {
  local name="$1"
  # If it has a .sh suffix, strip it
  name="${name%.sh}"
  # If it has a .md suffix, strip it
  name="${name%.md}"

  # Try exact path match first
  if [[ -f "$SCRIPT_REF/$name.md" ]]; then
    echo "$SCRIPT_REF/$name.md"
    return 0
  fi

  # Search by basename
  local results
  results=$(find "$SCRIPT_REF" -name "${name}.md" 2>/dev/null | head -5)
  local count
  count=$(echo "$results" | grep -c . || true)

  if [[ "$count" -eq 0 ]]; then
    # Broader search — match anywhere in filename
    results=$(find "$SCRIPT_REF" -name "*${name}*.md" 2>/dev/null | head -5)
    count=$(echo "$results" | grep -c . || true)
  fi

  if [[ "$count" -eq 0 ]]; then
    echo "NOT FOUND: No archive matching '$name'"
    return 1
  fi

  if [[ "$count" -gt 1 ]]; then
    echo "AMBIGUOUS: Multiple matches for '$name':"
    echo "$results"
    return 1
  fi

  echo "$results"
}

restore_one() {
  local md_file="$1"
  local source_rel
  source_rel=$(extract_source "$md_file")
  local expected_checksum
  expected_checksum=$(extract_checksum "$md_file")

  local target_path="$DOTFILES_SRC/${source_rel#dotfiles/scripts/}"

  echo "Restoring: $source_rel"

  if [[ -z "$source_rel" || "$source_rel" == "null" ]]; then
    echo "  ERROR: No source field in $md_file"
    return 1
  fi

  # Extract code block
  local content
  content=$(extract_code_block "$md_file")

  if [[ -z "$content" ]]; then
    echo "  ERROR: No bash code block found in $md_file"
    return 1
  fi

  # Write to temp file first
  local tmp_file
  tmp_file=$(mktemp)
  echo "$content" > "$tmp_file"

  # Verify checksum
  local actual_checksum
  actual_checksum=$(sha256sum "$tmp_file" | cut -d' ' -f1)

  if [[ "$actual_checksum" != "$expected_checksum" ]]; then
    echo "  CHECKSUM MISMATCH: expected $expected_checksum, got $actual_checksum"
    rm -f "$tmp_file"
    return 1
  fi

  echo "  Checksum verified: $actual_checksum"

  # Check if target exists and show diff
  if [[ -f "$target_path" ]]; then
    echo "  Changes vs live:"
    diff "$target_path" "$tmp_file" 2>/dev/null | head -20 || true
    echo
    printf "  Overwrite? [y/N] "
    read -r reply
    case "$reply" in
      [yY]|[yY][eE][sS]) ;;
      *) echo "  Skipped."; rm -f "$tmp_file"; return 0 ;;
    esac
  fi

  # Ensure target directory exists
  mkdir -p "$(dirname "$target_path")"

  # Write and set permissions
  cp "$tmp_file" "$target_path"
  chmod +x "$target_path"
  rm -f "$tmp_file"

  echo "  Restored: $target_path"

  # Git status preview
  if git -C "$DOTFILES_SRC" rev-parse --git-dir >/dev/null 2>&1; then
    echo
    echo "  Git status:"
    git -C "$DOTFILES_SRC" status --short "$target_path" 2>/dev/null || true
  fi
}

list_all() {
  echo "Restorable scripts:"
  find "$SCRIPT_REF" -name "*.md" | sort | while read -r f; do
    local src
    src=$(extract_source "$f" 2>/dev/null || echo "unknown")
    printf "  %-50s (source: %s)\n" "${f#$SCRIPT_REF/}" "$src"
  done
}

check_all() {
  local errors=0
  local total=0

  while IFS= read -r -d '' f; do
    total=$((total + 1))
    local expected
    expected=$(extract_checksum "$f")
    local content
    content=$(extract_code_block "$f")
    local actual
    actual=$(echo "$content" | sha256sum | cut -d' ' -f1)

    if [[ "$actual" != "$expected" ]]; then
      echo "FAIL: ${f#$SCRIPT_REF/} (expected $expected, got $actual)"
      errors=$((errors + 1))
    fi
  done < <(find "$SCRIPT_REF" -name "*.md" -print0)

  if [[ "$errors" -eq 0 ]]; then
    echo "All $total archives verified — checksums match."
  else
    echo "$errors / $total archives have checksum errors."
    return 1
  fi
}

case "${1:-}" in
  --list)   list_all ;;
  --status) check_all ;;
  --all)
    echo "Restoring all scripts..."
    while IFS= read -r -d '' f; do
      restore_one "$f"
      echo
    done < <(find "$SCRIPT_REF" -name "*.md" -print0)
    ;;
  *)
    if [[ -z "${1:-}" ]]; then
      echo "Usage: vault-restore <name>    # search and restore"
      echo "       vault-restore --all     # restore everything"
      echo "       vault-restore --list    # list archives"
      echo "       vault-restore --status  # verify checksums"
      exit 1
    fi

    archive_path=$(find_archive "$1")
    if [[ ! -f "$archive_path" ]]; then
      echo "$archive_path"
      exit 1
    fi
    restore_one "$archive_path"
    ;;
esac
