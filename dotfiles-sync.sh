#!/usr/bin/env bash
# dotfiles-sync.sh — Vault → dotfiles one-way mirror sync
#
# Source of truth:   ~/vault/dotfiles/
# Mirror targets:    ~/dotfiles/ (user env)
#                    ~/infra/    (automation scripts, subtree of vault/dotfiles/scripts/)
#
# Usage:
#   ./dotfiles-sync.sh           # Dry run (show what would change)
#   ./dotfiles-sync.sh --apply   # Actually sync (with confirmation)
#   ./dotfiles-sync.sh --status  # Show diff status only
#   ./dotfiles-sync.sh --force   # Sync without confirmation

set -euo pipefail

VAULT_SRC="$HOME/vault/dotfiles"
DOTFILES_MIRROR="$HOME/dotfiles"
INFRA_MIRROR="$HOME/infra"
MIN_FILES=10
RSYNC_OPTS="-av --delete --exclude=.git"

preflight_check() {
  local src="$1" name="$2"
  if [ ! -d "$src" ]; then
    echo "ERROR: Source $name does not exist: $src"
    exit 1
  fi
  local count
  count=$(find "$src" -maxdepth 1 -not -name '.git' -not -name '.' | wc -l)
  if [ "$count" -lt "$MIN_FILES" ]; then
    echo "ERROR: Source $name has only $count entries (min $MIN_FILES) — refusing to sync with --delete"
    exit 1
  fi
}

confirm_sync() {
  echo "WARNING: This will OVERWRITE mirror targets with vault contents."
  echo "  Source: $VAULT_SRC"
  echo "  Target: $DOTFILES_MIRROR"
  echo "  Target: $INFRA_MIRROR"
  echo "  Mode:   rsync $RSYNC_OPTS"
  echo
  printf "Proceed? [y/N] "
  read -r reply
  case "$reply" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) echo "Aborted."; exit 0 ;;
  esac
}

tag_rollback() {
  local ts
  ts=$(date +%Y%m%d-%H%M%S)
  if git -C "$DOTFILES_MIRROR" rev-parse --git-dir >/dev/null 2>&1; then
    (cd "$DOTFILES_MIRROR" && git tag "pre-sync-$ts" 2>/dev/null && echo "  Rollback tag: pre-sync-$ts") || true
  fi
}

dry_run=true
case "${1:-}" in
  --apply) dry_run=false ;;
  --force)
    dry_run=false
    NO_CONFIRM=true
    ;;
  --status)
    rsync -ah --dry-run --delete --exclude=.git "$VAULT_SRC/" "$DOTFILES_MIRROR/" 2>/dev/null | grep -v '/$' | head -20
    exit 0
    ;;
esac

preflight_check "$VAULT_SRC" "vault/dotfiles"
[ -d "$DOTFILES_MIRROR" ] || echo "WARN: dotfiles mirror missing — will be created"
[ -d "$INFRA_MIRROR" ] || echo "WARN: infra mirror missing — will be created"

echo "=== dotfiles mirror ==="
echo "Source: $VAULT_SRC"
echo "Target: $DOTFILES_MIRROR"
echo

if $dry_run; then
  echo "[DRY RUN] Would sync:"
  rsync $RSYNC_OPTS --dry-run "$VAULT_SRC/" "$DOTFILES_MIRROR/" 2>/dev/null | grep -v '/$'
  echo
  echo "Run with --apply to execute."
else
  [ "${NO_CONFIRM:-}" = true ] || confirm_sync
  echo "Tagging pre-sync state..."
  tag_rollback
  echo "Syncing dotfiles mirror..."
  rsync $RSYNC_OPTS "$VAULT_SRC/" "$DOTFILES_MIRROR/"
  echo "Committing and pushing dotfiles mirror..."
  (cd "$DOTFILES_MIRROR" && git add -A && git commit -m "sync from vault $(date +%Y-%m-%d)" && git push) || echo "  (git commit/push skipped — nothing to commit or remote unavailable)"
  echo "Done."
fi

echo
echo "=== infra mirror (scripts only) ==="
echo "Source: $VAULT_SRC/scripts"
echo "Target: $INFRA_MIRROR"

if $dry_run; then
  echo "[DRY RUN] Would sync:"
  rsync $RSYNC_OPTS --dry-run "$VAULT_SRC/scripts/" "$INFRA_MIRROR/" 2>/dev/null | grep -v '/$'
  echo
  echo "Run with --apply to execute."
else
  echo "Syncing infra mirror..."
  rsync $RSYNC_OPTS "$VAULT_SRC/scripts/" "$INFRA_MIRROR/"
  echo "Done."
fi
