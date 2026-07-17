---
tags: [reference, bugs, workarounds]
aliases: [known-issues, bugs, workarounds, temporary-hacks]
updated: 2026-06-15
---

# Bugs & Workarounds

Active workarounds for upstream bugs. Revisit each entry after a system update
to check if the fix has shipped.

## 2026-06-08 — KIO security dialog blocks .exe double-click

**Bug:** KDE#519773 ([bugs.kde.org](https://bugs.kde.org/show_bug.cgi?id=519773))
**Fixed in:** KIO commit `d51a661` (Pan Zhang, Jun 4 2026) → KIO ≥6.26.1
**Remove when:** `kio` package ≥ 6.26.1 is installed.

### Root cause

`OpenUrlJob::handleBinaries()` in KIO 6.26.0 uses `Q_UNUSED(shouldExecute)` in the
dialog lambda and unconditionally calls `handleBinariesHelper()`. That helper checks
`m_runExecutables` (set by the dialog callback before invoking the lambda), but the
`behaviourOnLaunch=open` path calls `executeFile(false)` directly, which sets
`m_runExecutables=false` and triggers "For security reasons, launching executables
is not allowed in this context."

### Workaround

Set `behaviourOnLaunch=alwaysAsk` in `~/.config/kiorc`. The Launch dialog button
sets `m_runExecutables=true` before the buggy check, bypassing the security error.

**File:** `~/.config/kiorc`
**Current value:**
```ini
[Executable scripts]
behaviourOnLaunch=alwaysAsk
```
**Restore when fix ships:** Change back to `behaviourOnLaunch=open`.

## 2026-06-08 — .exe files launch wrong app (protontricks vs protontricks-launch)

**Bug:** N/A — `protontricks-launch.desktop` missing
`application/vnd.microsoft.portable-executable` in MimeType
**Remove when:** Upstream .desktop file includes the missing MIME type.

### Workaround

1. Change the MIME default to use `protontricks-launch.desktop`
2. Add the missing MIME type to the local copy of the .desktop file

**File:** `~/.config/mimeapps.list`
**Current value:**
```ini
[Default Applications]
application/vnd.microsoft.portable-executable=protontricks-launch.desktop;
```

**File:** `~/.local/share/applications/protontricks-launch.desktop`
**Current MimeType (local override):**
```
MimeType=application/vnd.microsoft.portable-executable;application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
```

**Restore when:** protontricks upstream adds the missing MIME type.

## Related

- [[reference/faq]] — Common questions
- [[known-issues/temporary-hacks]] — Original source file for these entries
