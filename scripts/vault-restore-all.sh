#!/usr/bin/env bash
# vault-restore-all — Bulk disaster recovery from vault archives
#
# Restores every restorable script from vault/script-reference/
# back to dotfiles/scripts/.
#
# After a disk failure:
#   git clone git@github.com:InnerTic/vault.git ~/vault
#   vault-restore-all
#   git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles
#   sync

set -euo pipefail

VAULT="$HOME/vault"
RESTORE_SCRIPT="$VAULT/dotfiles/scripts/vault-restore.sh"

if [[ ! -f "$RESTORE_SCRIPT" ]]; then
  # Fallback if vault is cloned but restore script isn't at expected path yet
  RESTORE_SCRIPT="$HOME/dotfiles/scripts/vault-restore.sh"
fi

if [[ ! -f "$RESTORE_SCRIPT" ]]; then
  echo "ERROR: vault-restore.sh not found."
  echo "Try: curl -o ~/vault-restore.sh https://raw.githubusercontent.com/InnerTic/vault/main/dotfiles/scripts/vault-restore.sh"
  exit 1
fi

echo "=== vault-restore-all ==="
echo "Source: $VAULT/script-reference/"
echo "Target: $HOME/dotfiles/scripts/"
echo

# Verify the archive integrity first
bash "$RESTORE_SCRIPT" --status || {
  echo
  echo "WARNING: Some archives have checksum errors."
  printf "Continue anyway? [y/N] "
  read -r reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
}

echo

# Run restore on everything (non-interactive by piping yes)
bash "$RESTORE_SCRIPT" --all

echo
echo "=== Done ==="
echo "Run 'dotfiles-sync.sh --status' to check mirror state."
