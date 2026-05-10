# KDE/Plasma Settings Backup - Manual Restore Instructions

Copy these files back to ~/.config/ after a fresh OS install to restore your KDE desktop settings.

## Files to Backup (Location → Where to Restore)

### Core KDE Settings (~/.config/)
```
kdeglobals                    → ~/.config/kdeglobals
kded5rc                     → ~/.config/kded5rc
kded6rc                     → ~/.config/kded6rc
kglobalshortcutsrc           → ~/.config/kglobalshortcutsrc
kscreenlockerrc             → ~/.config/kscreenlockerrc
kwinoutputconfig.json       → ~/.config/kwinoutputconfig.json
kwinrc                     → ~/.config/kwinrc
dolphinrc                  → ~/.config/dolphinrc
plasmanotifyrc             → ~/.config/plasmanotifyrc
plasma-localerc            → ~/.config/plasma-localerc
xdg-desktop-portal-kderc   → ~/.config/xdg-desktop-portal-kderc
```

### Plasma Desktop Layout (~/.config/)
```
plasma-org.kde.plasma.desktop-appletsrc  → ~/.config/plasma-org.kde.plasma.desktop-appletsrc
plasmarc                    → ~/.config/plasmarc
plasmashellrc              → ~/.config/plasmashellrc
plasma-workspace/          → ~/.config/plasma-workspace/
kdedefaults/               → ~/.config/kdedefaults/
```

### Dolphin File Manager (~/.config/)
```
dolphinrc                   → ~/.config/dolphinrc
~/.local/share/dolphin/      → ~/.local/share/dolphin/
```

### KDE Connect (~/.config/)
```
kdeconnect/                → ~/.config/kdeconnect/
```

### GTK Settings (if using GTK apps)
```
gtk-3.0/                   → ~/.config/gtk-3.0/
gtk-4.0/                   → ~/.config/gtk-4.0/
gtkrc                      → ~/.config/gtkrc
gtkrc-2.0                  → ~/.config/gtkrc-2.0
```

### Monitor/Display Settings (~/.config/)
```
kwinoutputconfig.json       → ~/.config/kwinoutputconfig.json
monitors.xml              → ~/.config/monitors.xml  (if exists)
```

### Autostart (~/.config/)
```
autostart/                 → ~/.config/autostart/
```

## Quick Copy Command (Run After Fresh Install)
```bash
# Create dirs first
mkdir -p ~/.config/kdeconnect ~/.config/kdedefaults ~/.config/plasma-workspace ~/.local/share/dolphin

# Copy files
cp kdeglobals ~/.config/
cp kded5rc ~/.config/
cp kded6rc ~/.config/
cp kglobalshortcutsrc ~/.config/
cp kscreenlockerrc ~/.config/
cp kwinoutputconfig.json ~/.config/
cp kwinrc ~/.config/
cp dolphinrc ~/.config/
cp plasmanotifyrc ~/.config/
cp plasma-localerc ~/.config/
cp xdg-desktop-portal-kderc ~/.config/
cp plasma-org.kde.plasma.desktop-appletsrc ~/.config/
cp plasmarc ~/.config/
cp plasmashellrc ~/.config/

# Copy dirs
cp -r plasma-workspace ~/.config/
cp -r kdeconnect ~/.config/
cp -r kdedefaults ~/.config/

# GTK
cp -r gtk-3.0 ~/.config/
cp -r gtk-4.0 ~/.config/
cp gtkrc ~/.config/
cp gtkrc-2.0 ~/.config/

# Autostart
cp -r autostart ~/.config/

# Dolphin
cp -r ~/.local/share/dolphin ~/.local/share/
```

## What Each File Controls

| File | Controls |
|------|----------|
| kdeglobals | Global KDE settings, colors, file dialogs |
| kwinrc | Window manager behavior |
| kwinoutputconfig.json | Multi-monitor layout |
| dolphinrc | File manager view settings |
| plasma-org.kde.plasma.desktop-appletsrc | Desktop widgets, panel layout |
| kglobalshortcutsrc | Custom keyboard shortcuts |
| kscreenlockerrc | Screen lock settings |
| autostart/ | Apps that start on login |

## Backup These Locations Too
```
~/.config/kde*
~/.config/plasma*
~/.config/dolphinrc
~/.config/kdeglobals
~/.local/share/dolphin/
~/.local/share/icons/
```

---
*Last updated: 2026-04-19*