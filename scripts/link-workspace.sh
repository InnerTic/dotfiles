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
#   Total OS refresh: wipe /, /home completely, then restore working state
#   from /mnt/workspace. Only essentials are symlinked — everything else
#   regenerates fresh.
#
# Idempotent — safe to run multiple times.
# =============================================================================

set -euo pipefail

WORKSPACE="/mnt/workspace"
DRY_RUN=true

# ONLY these directories are persisted across OS refreshes
# Everything else in /home is excluded and regenerates
SYMLINKS=(
  ".ssh:.ssh"                # SSH keys
  ".librewolf:.librewolf"    # Browser profiles/bookmarks
  ".openclaw:.openclaw"      # Custom dev tool config
  ".opencode:.opencode"      # Custom dev tool config
  "dotfiles:dotfiles"        # Dotfiles repo
  "openclaw:openclaw"        # Project directory
)

# --- helpers ---

color() { tput setaf "$1"; }
reset() { tput sgr0; }

info()  { echo -e "$(color 2)[*]$(reset) $*"; }
warn()  { echo -e "$(color 3)[!]$(reset) $*"; }
error() { echo -e "$(color 1)[!!]$(reset) $*" >&2; }
dry()   { echo -e "$(color 6)[DRY]$(reset) $*"; }

# Validate that workspace is on a different filesystem than home
validate_workspace() {
  if [ ! -d "$WORKSPACE" ]; then
    error "Workspace $WORKSPACE not found. Mount it first."
    return 1
  fi

  local home_dev
  local ws_dev
  home_dev=$(stat -c %d "$HOME") || {
    error "Cannot stat $HOME"
    return 1
  }
  ws_dev=$(stat -c %d "$WORKSPACE") || {
    error "Cannot stat $WORKSPACE"
    return 1
  }

  if [ "$home_dev" = "$ws_dev" ]; then
    error "Workspace is on the same filesystem as \$HOME. This would create symlink cycles."
    error "Mount $WORKSPACE on a separate filesystem and try again."
    return 1
  fi

  return 0
}

merge_and_link() {
  local home_path="$1"
  local ws_path="$2"
  local name="$3"

  # Already correctly linked
  if [ -L "$home_path" ] && [ "$(readlink "$home_path")" = "$ws_path" ]; then
    info "Already linked: $name"
    return 0
  fi

  # Wrong symlink — remove it
  if [ -L "$home_path" ]; then
    local current_target
    current_target=$(readlink "$home_path")
    warn "Wrong symlink target, removing: $name → $current_target"
    $DRY_RUN || rm "$home_path"
  fi

  # Real directory exists in home — merge into workspace
  if [ -d "$home_path" ] && [ ! -L "$home_path" ]; then
    if $DRY_RUN; then
      dry "Would merge $home_path/ → $ws_path/"
      return 0
    fi
    mkdir -p "$ws_path"
    info "Merging $home_path/ → $ws_path/ (workspace version wins on conflicts)..."
    rsync -a --info=progress2 "$home_path/" "$ws_path/"
    rm -rf "$home_path"
  fi

  # Workspace path missing — create it
  if [ ! -e "$ws_path" ]; then
    if $DRY_RUN; then
      dry "Would create directory $ws_path"
    else
      mkdir -p "$ws_path"
    fi
  fi

  # Safety check: ensure we're not about to overwrite a real file/dir in apply mode
  if ! $DRY_RUN && [ -e "$home_path" ] && [ ! -L "$home_path" ]; then
    error "Cannot create symlink: $home_path still exists and is not a symlink (merge may have failed)"
    return 1
  fi

  # Create the symlink
  if $DRY_RUN; then
    dry "Would link $name → $ws_path"
  else
    ln -s "$ws_path" "$home_path"
    info "Linked $name → $ws_path"
  fi

  return 0
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
  echo "  (Only these essentials are persisted; everything else regenerates)"
  echo
  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    ws_part="${entry##*:}"
    home_path="$HOME/$name"
    ws_path="$WORKSPACE/$ws_part"

    if [ -L "$home_path" ]; then
      local target
      target=$(readlink "$home_path")
      if [ -e "$home_path" ]; then
        if [ "$target" = "$ws_path" ]; then
          echo "  ✅ $name → $ws_path"
        else
          echo "  ⚠️  $name → $target (wrong target; should be $ws_path)"
        fi
      else
        echo "  🔗 $name → $target (broken symlink)"
      fi
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
  info "Merging persisted directories → $WORKSPACE and creating symlinks..."
  echo

  validate_workspace || return 1

  local had_error=0
  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    ws_part="${entry##*:}"
    home_path="$HOME/$name"
    ws_path="$WORKSPACE/$ws_part"

    merge_and_link "$home_path" "$ws_path" "$name" || had_error=1
  done

  if $DRY_RUN; then
    echo
    echo "--- DRY RUN — no changes made. Re-run with --apply to execute. ---"
  fi

  return "$had_error"
}

do_revert() {
  warn "Removing symlinks. Workspace data stays on $WORKSPACE (not deleted)."
  echo

  for entry in "${SYMLINKS[@]}"; do
    name="${entry%%:*}"
    home_path="$HOME/$name"
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
    echo "  --apply    Merge persisted dirs → workspace, create symlinks"
    echo "  --revert   Remove symlinks (workspace data preserved)"
    echo "  --status   Show current state"
    echo "  --dry-run  Preview without making changes"
    echo
    if [ -z "${1:-}" ]; then
      do_status
      echo
      DRY_RUN=true
      do_apply
    fi
    ;;
esac
