# GPG Key Backup & Restore

## Backup

```bash
~/dotfiles/scripts/gnupg-backup.sh
```

Creates `~/Vault/Infrastructure/Identity/GPG/` with:

| File | Encrypted | Content |
|------|-----------|---------|
| `gpg-public.asc` | No | Public key (safe to share) |
| `gpg-private.asc.gpg` | Yes (AES) | Private key — **never store without encryption** |
| `revoke-cert.asc` | No | Revocation certificate |
| `ownertrust.txt` | No | Ownertrust database |
| `README.md` | No | [[QUICK-START]] instructions |

The decryption passphrase is **not** stored in the vault — keep it in your password manager.

---

## Restore (fresh system)

```bash
# Decrypt and import private key
gpg -d ~/Vault/Infrastructure/Identity/GPG/gpg-private.asc.gpg | gpg --import

# Import public key (if private key import didn't already pull it)
gpg --import ~/Vault/Infrastructure/Identity/GPG/gpg-public.asc

# Restore ownertrust
gpg --import-ownertrust < ~/Vault/Infrastructure/Identity/GPG/ownertrust.txt

# Verify
gpg --list-secret-keys --keyid-format LONG
```

---

## Bootstrap module

`scripts/bootstrap/modules/70-gnupg.sh` handles config + public keys automatically on any profile (desktop, server, container). The private key is **never** part of the dotfiles or bootstrap — it must be restored manually from the encrypted vault backup.
