# Temporary Hacks

Workarounds that exist only until upstream fixes are packaged.
Revisit each entry after a system update to check if the fix has shipped.

---

## 2026-06-08 — KIO security dialog blocks .exe double-click

**Bug:** KDE#519773 ([[[bugs-and-workarounds]].kde.org](https://[[bugs-and-workarounds]].kde.org/show_bug.cgi?id=519773))
**Fixed in:** KIO commit `d51a661` (Pan Zhang, Jun 4 2026) → KIO ≥6.26.1
**Remove when:** `kio` package ≥ 6.26.1 is installed.

### Root cause
`OpenUrlJob::handleBinaries()` in KIO 6.26.0 uses `Q_UNUSED(shouldExecute)` in the dialog lambda and unconditionally calls `handleBinariesHelper()`. That helper checks `m_runExecutables` (set by the dialog callback before invoking the lambda), but the `behaviourOnLaunch=open` path calls `executeFile(false)` directly, which sets `m_runExecutables=false` and triggers "For security reasons, launching executables is not allowed in this context."

### Workaround
Set `behaviourOnLaunch=alwaysAsk` in `~/.config/kiorc`. The Launch dialog button sets `m_runExecutables=true` before the buggy check, bypassing the security error.

**File:** `~/.config/kiorc`
**Original value:**
```ini
[Executable scripts]
behaviourOnLaunch=open
```
**Current value:**
```ini
[Executable scripts]
behaviourOnLaunch=alwaysAsk
```

**Restore when fix ships:** Change back to `behaviourOnLaunch=open`.

---

## 2026-06-08 — .exe files launch wrong app (protontricks vs protontricks-launch)

**Bug:** N/A — `protontricks-launch.desktop` missing `application/vnd.microsoft.portable-executable` in MimeType
**Remove when:** Upstream .desktop file includes the missing MIME type (check after protontricks update).

### Workaround
1. Change the MIME default to use `protontricks-launch.desktop`.
2. Add the missing MIME type to the local copy of the .desktop file.

**File:** `~/.config/mimeapps.list`
**Changed:** `[Default Applications]` entry for `application/vnd.microsoft.portable-executable`
**Original value:**
```ini
application/vnd.microsoft.portable-executable=protontricks.desktop;
```
**Current value:**
```ini
application/vnd.microsoft.portable-executable=protontricks-launch.desktop;
```
**Also updated:** `[Added Associations]` for consistency.

**File:** `~/.local/share/applications/protontricks-launch.desktop`
**Original MimeType (from `/usr/share/applications/protontricks-launch.desktop`):**
```
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
```
**Current MimeType (local override):**
```
MimeType=application/vnd.microsoft.portable-executable;application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
```

**Restore when:** Ideally protontricks upstream adds `application/vnd.microsoft.portable-executable` to the .desktop file. Check after protontricks package update.
