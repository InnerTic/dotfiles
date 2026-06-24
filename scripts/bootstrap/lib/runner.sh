#!/usr/bin/env sh
# Bootstrap runner — iterates MODULES list, sources each
[ -z "${MODULES:-}" ] && MODULES=$(cd "$SCRIPT_DIR/modules" && echo *.sh)

echo "→ Bootstrapping dotfiles from $DOTFILES [$PROFILE_LABEL]"
echo

for m in $MODULES; do
  module="$SCRIPT_DIR/modules/$m"
  [ -f "$module" ] || continue
  . "$module"
  echo
done

echo "✓ Done. Restart your shell or source the config."
