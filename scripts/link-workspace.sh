#!/bin/bash
# =============================================================================
# WORKSPACE SYMLINK SETUP — merge home dirs into /mnt/workspace, then symlink
# =============================================================================
# Usage:
#   ./link-workspace.sh              # preview mode (dry-run)
#   ./link-workspace.sh --apply      # merge home → workspace, create symlinks
#   ./link-workspace.sh --revert     # remove symlinks, keep workspace data
#   ./link-workspace.sh --status     # show current state
#
# Philosophy:
#   Existing home dir contents get merged (rsync) into the workspace,
#   NOT backed up to a separate archive. The workspace is the canonical
#   location. After reinstall, run --apply and your tools/configs are
#   back where they belong — no data left behind in /home.
#
# Things that stay in real /home (NOT symlinked):
#   .steam, Downloads, Documents, Pictures, Music, Videos
#   .cache, .dbus, .fontconfig, .thumbnails
#
# Idempotent — safe to run multiple times.
# =============================================================================

set -euo pipefail

WORKSPACE="/mnt/workspace"
DRY_RUN=true

# Pairs: what in ~ should link where on $WORKSPACE
# Format: "home_name:workspace_name"
SYMLINKS=(
  ".openclaw:.openclaw"
  ".opencode:.opencode"
  ".local:local"
  ".ssh:.ssh"
  "config:config"
  "openclaw:openclaw"
  "memory:memory"
  "state:state"
  "backups:backups"
  "scripts:scripts"
  "logs:logs"
  "openweb:openweb"
)

EXCLUDED=(
  ".steam"
  "Downloads"
  "Documents"
  "Pictures"
  "Music"
  "Videos"
  ".cache"
  ".dbus"
  ".fontconfig"
  ".thumbnails"
)

# --- helpers ---

color() { tput setaf "$1"; }
reset() { tput sgr0; }

info()  { echo -e "$(color 2)[*]$(reset) $*"; }
warn()  { echo -e "$(color 3)[!]$(reset) $*"; }
error() { echo -e "$(color 1)[!!]$(reset) $*" >&2; }
dry()   { echo -e "$(color 6)[DRY]$(reset) $*"; }

is_excluded() {
  local name="$1"
  for x in "${EXCLUDED[@]}"; do
    [[ "$name" == "$x" ]] && return 0
  done
  return 1
}

merge_and_link() {
  local home_path="$1"
  local ws_path="$2"
  local name="$3"

  # Already correctly linked
  if [ -L "$home_path" ] && [ "$(readlink "$home_path")" = "$ws_path" ]; then
    info "Already linked: $name"
    return
  fi

  # Wrong symlink — remove it
  if [ -L "$home_path" ]; then
    warn "Wrong symlink target, removing: $name → $(readlink "$home_path")"
    $DRY_RUN || rm "$home_path"
  fi

  # Real directory exists in home — merge into workspace
  if [ -d "$home_path" ] && [ ! -L "$home_path" ]; then
    if $DRY_RUN; then
      dry "Would merge $home_path/ → $ws_path/"
      return
    fi
    mkdir -p "$ws_path"
    info "Merging $home_path/ → $ws_path/ ..."
    rsync -a --info=progress2 "$home_path/" "$ws_path/"
    rm -rf "$home_path"
  fi

  # Workspace path missing — create it
  if [ ! -e "$ws_path" ]; then
    $DRY_RUN || mkdir -p "$ws_path"
  fi

  # Create the symlink
  if $DRY_RUN; then
    dry "Would link $name → $ws_path"
  else
    ln -sf "$ws_path" "$home_path"
    info "Linked $name → $ws_path"
  fi
}

remove_symlink() {
  local home_path="$1"
  local name="$2"

  if [ -L "$home_path" ]; then
    if $DRY_RUN; then
      dry "Would remove symlink $name"
    else
      rm "$home_path"
      info "Removed symlink $name"
    fi
  fi
}

# --- commands ---

do_status() {
  echo "Symlink status for workspace targets:"
  echo "  Workspace: $WORKSPACE"
  echo
  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    ws_part="${entry##*:}"
    home_path="$HOME/$name"
    ws_path="$WORKSPACE/$ws_part"

    if is_excluded "$name"; then
      echo "  ⏭️  $name  (excluded)"
      continue
    fi

    if [ -L "$home_path" ]; then
      target=$(readlink "$home_path")
      [ "$target" = "$ws_path" ] \
        && echo "  ✅ $name → $ws_path" \
        || echo "  ⚠️  $name → $target (wrong target)"
    elif [ -d "$home_path" ]; then
      echo "  📁 $name  (real dir, not linked)"
    elif [ -e "$home_path" ]; then
      echo "  🔸 $name  (file, not a directory)"
    else
      echo "  ❌ $name  (does not exist)"
    fi
  done
}

do_apply() {
  info "Merging home dirs → $WORKSPACE and creating symlinks..."
  echo

  [ -d "$WORKSPACE" ] || { error "Workspace $WORKSPACE not found. Mount it first."; exit 1; }

  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    ws_part="${entry##*:}"
    home_path="$HOME/$name"
    ws_path="$WORKSPACE/$ws_part"

    is_excluded "$name" && continue

    merge_and_link "$home_path" "$ws_path" "$name"
  done

  if $DRY_RUN; then
    echo
    echo "--- DRY RUN — no changes made. Re-run with --apply to execute. ---"
  fi
}

do_revert() {
  warn "Removing symlinks. Workspace data stays on $WORKSPACE (not deleted)."
  echo

  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    home_path="$HOME/$name"
    is_excluded "$name" && continue
    remove_symlink "$home_path" "$name"
  done
}

# --- main ---

case "${1:-}" in
  --apply)
    DRY_RUN=false
    do_apply
    ;;
  --revert)
    DRY_RUN=false
    do_revert
    ;;
  --status)
    DRY_RUN=false
    do_status
    ;;
  --dry-run|--dryrun)
    DRY_RUN=true
    do_status
    echo
    do_apply
    ;;
  *)
    echo "Usage: $(basename "$0") [--apply | --revert | --status | --dry-run]"
    echo
    echo "  No args    Show status + dry-run preview"
    echo "  --apply    Merge home → workspace, create symlinks"
    echo "  --revert   Remove symlinks (workspace data preserved)"
    echo "  --status   Show current state"
    echo "  --dry-run  Preview without making changes"
    echo
    if [ -z "${1:-}" ]; then
      DRY_RUN=false
      do_status
      echo
      DRY_RUN=true
      do_apply
    fi
    ;;
esac
