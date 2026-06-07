# KDE/Plasma Workarounds — Tracked Bugs

Workarounds for KDE bugs that need periodic review for upstream fixes.
Check each entry's **Review-By** date and remove the workaround when fixed.

---

## KDE 6.6.3: Dolphin refuses to launch .exe files via double-click

**Status**: Not fixed — KDE bug, no config key workaround exists.

**Symptoms**: Double-clicking a .exe file in Dolphin shows "For security reasons,
launching executables is not allowed in this context." even though the correct
handler (wine/protontricks) is set in file associations. Right-click → Open With
works fine.

**Root cause**: KDE 6.6.3 changed behavior in Dolphin's double-click handler
(KRun/ApplicationLauncherJob). It blocks `application/x-ms-dos-executable`
files from being run and then fails to fall through to the MIME association.
This affects Dolphin 25.12.3 / Plasma 6.6.3+.

**Affects**: CachyOS (extra repo) protontricks v1.14.1-1 and similar.

**Workaround**: None via config. Right-click → Open With → protontricks works.
Or use the context menu's top entry.

**Review-By**: 2026-09-01 (check if Plasma 6.7.x or Dolphin 26.x fixes it)

**Reference**: https://discuss.kde.org/t/double-clicking-exe-files-doesnt-launch-the-chosen-file-associated-app/45589

---

## protontricks: missing `wine` icon in default icon theme

**Status**: Not fixed — upstream protontricks uses `Icon=wine` but no
default-theme icon exists.

**Symptoms**: protontricks has no icon in menus or launchers (shows blank).

**Root cause**: The protontricks .desktop file (`/usr/share/applications/
protontricks.desktop`) uses `Icon=wine`, but neither Breeze nor hicolor
provides a `wine` icon. The package ships no icon of its own.

**Workaround**:
```bash
mkdir -p ~/.local/share/icons/hicolor/scalable/apps
# Symlink to an existing wine icon if available, or use the protontricks SVG:
cp /usr/share/icons/hicolor/scalable/apps/protontricks.svg \
   ~/.local/share/icons/hicolor/scalable/apps/wine.svg
```
This puts `wine.svg` in the user's hicolor override dir — it will be found when
Breeze falls through to hicolor. No `index.theme` needed.

**Review-By**: 2026-09-01 (check if protontricks package ships its own icon
or upstream fixes Icon= in the .desktop file)

---

## Template for New Entries

```markdown
## [Title]

**Status**: Not fixed / Fixed-upstream-not-packaged / Workaround-only

**Symptoms**:

**Root cause**:

**Workaround**:

**Review-By**: YYYY-MM-DD

**Reference**: <url>
```
