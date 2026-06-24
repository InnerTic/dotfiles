#!/usr/bin/env sh
# Module: GnuPG config + public keys
header "GnuPG"

GPGDIR="$HOME/.gnupg"
DOTGPG="$DOTFILES/gnupg"

# --- config ---
if [ -f "$DOTGPG/common.conf" ]; then
  mkdir -p "$GPGDIR"
  chmod 700 "$GPGDIR"
  cp "$DOTGPG/common.conf" "$GPGDIR/common.conf"
  chmod 600 "$GPGDIR/common.conf"
  ok "config"
fi

# --- public keys ---
if [ -f "$DOTGPG/pubkeys.asc" ]; then
  # Only import if the keyring doesn't already have our key
  if ! gpg --list-keys 2>/dev/null | grep -q "$(gpg --show-keys "$DOTGPG/pubkeys.asc" 2>/dev/null | head -1 | cut -d' ' -f3)"; then
    gpg --import "$DOTGPG/pubkeys.asc" 2>/dev/null && ok "public keys imported"
  else
    ok "public keys (already present)"
  fi
fi

# --- permissions ---
chmod 700 "$GPGDIR" 2>/dev/null || true
