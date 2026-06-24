#!/usr/bin/env sh
# GnuPG backup — exports private key, encrypts it, stores in vault
set -e

VAULT_DIR="${1:-$HOME/Vault/Infrastructure/Identity/GPG}"

# Find the user's key (most recent secret key)
KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep '^sec' | head -1 | sed 's/.*\///' | cut -d' ' -f1)

if [ -z "$KEY_ID" ]; then
  echo "No secret keys found. Nothing to back up."
  exit 1
fi

FINGERPRINT=$(gpg --list-secret-keys --with-fingerprint --keyid-format LONG 2>/dev/null | grep -A1 '^sec' | head -2 | grep 'Key fingerprint' | sed 's/.*= //')
echo "Key: $KEY_ID"
echo "Fingerprint: $FINGERPRINT"
echo "Output: $VAULT_DIR"
echo

mkdir -p "$VAULT_DIR"
TMPDIR=$(mktemp -d)

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# Export public key (safe, unencrypted)
gpg --armor --export "$KEY_ID" > "$TMPDIR/gpg-public.asc"

# Export private key (sensitive — symmetric encrypt immediately)
gpg --armor --export-secret-keys "$KEY_ID" > "$TMPDIR/gpg-private.asc"
gpg -c "$TMPDIR/gpg-private.asc"
shred -u "$TMPDIR/gpg-private.asc" 2>/dev/null || rm "$TMPDIR/gpg-private.asc"

# Revocation certificate
REVOC=$(ls -t "$HOME/.gnupg/openpgp-revocs.d/$FINGERPRINT".rev 2>/dev/null | head -1)
if [ -f "$REVOC" ]; then
  cp "$REVOC" "$TMPDIR/revoke-cert.asc"
fi

# Ownertrust
gpg --export-ownertrust 2>/dev/null > "$TMPDIR/ownertrust.txt" || true

# Verify encrypted backup
echo "Verifying encrypted backup..."
gpg -d "$TMPDIR/gpg-private.asc.gpg" > /dev/null 2>&1 && echo "  OK — decrypts successfully" || { echo "  FAILED"; exit 1; }

# Move to vault
cp "$TMPDIR/gpg-public.asc" "$VAULT_DIR/"
cp "$TMPDIR/gpg-private.asc.gpg" "$VAULT_DIR/"
[ -f "$TMPDIR/revoke-cert.asc" ] && cp "$TMPDIR/revoke-cert.asc" "$VAULT_DIR/"
[ -f "$TMPDIR/ownertrust.txt" ] && cp "$TMPDIR/ownertrust.txt" "$VAULT_DIR/"

cat > "$VAULT_DIR/README.md" <<EOF
# GPG Key Backup — $KEY_ID

- \`gpg-public.asc\` — Public key (safe to share)
- \`gpg-private.asc.gpg\` — Encrypted private key (AES)
- \`revoke-cert.asc\` — Revocation certificate
- \`ownertrust.txt\` — Ownertrust database

## Recovery

\`\`\`bash
gpg -d $VAULT_DIR/gpg-private.asc.gpg | gpg --import
gpg --import-ownertrust < $VAULT_DIR/ownertrust.txt
\`\`\`

## Passphrase

The decryption passphrase is stored separately (password manager).
EOF

echo
echo "✓ Backed up to $VAULT_DIR"
ls -la "$VAULT_DIR/"
