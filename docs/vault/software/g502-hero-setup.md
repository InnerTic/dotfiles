---
title: Logitech G502 Hero Setup
tags:
  - software
  - hardware
  - mouse
  - g502
  - libratbag
---

# Logitech G502 Hero (SE) Setup

G502 Hero gaming mouse configuration — button remapping, known bugs, and libratbag build notes.

## Install

```bash
sudo pacman -S libratbag piper
```

`ratbagd` auto-starts via DBus — no manual enable needed.

## Button Layout

|libratbag idx | Physical button | Current mapping |
|---|---|---|
|0 | Left click | button 1 |
|1 | Right click | button 2 |
|2 | Middle click | button 3 |
|3 | G5 (rear thumb) — back | X11 button 4 (default browser back) |
|4 | G4 (front thumb) — C | KEY_C |
|5 | G6 (sniper/thumb rest) — V | KEY_V |
|6 | Scroll wheel left tilt | KEY_2 |
|7 | Scroll wheel right tilt | KEY_N |
|8 | DPI cycle | profile-cycle-up |
|9 | G-shift variant | KEY_N |
|10 | G-shift variant | KEY_2 |

## Button Mapping Commands

List current mapping:
```bash
for i in $(seq 0 10); do echo -n "Button $i: "; ratbagctl warbling-mara profile 0 button $i get 2>&1 | grep mapped; done
```

Set a button (profile 0 is active):
```bash
# X11 button (back/forward)
ratbagctl warbling-mara profile 0 button 3 action set button 4

# Plain key
ratbagctl warbling-mara profile 0 button 4 action set key KEY_C

# Macro
ratbagctl warbling-mara profile 0 button 5 action set macro +KEY_LEFTCTRL +KEY_LEFTALT KEY_C -KEY_LEFTCTRL -KEY_LEFTALT
```

## Known Bug: Stale Modifier Keys (libratbag #1853)

**Symptom**: When remapping a button from a macro with modifiers (e.g. `Ctrl+Alt+C`) to a plain key (`KEY_C`), the mouse firmware retains the old modifier — the key press still includes `Alt`, `Ctrl`, or `Meta`.

**Cause**: libratbag HID++ protocol code was not clearing modifier state before writing new key mappings. The mouse firmware retains stale modifier bits from previous mappings.

**Fix**: Build libratbag from git with PR #1843 (merged Jul 10, 2026):

```bash
git clone https://github.com/libratbag/libratbag.git /tmp/libratbag
cd /tmp/libratbag
meson setup builddir --prefix=/usr
ninja -C builddir
sudo ninja -C builddir install
sudo systemctl kill -s TERM ratbagd
```

Dependencies: `meson ninja check swig`

## Piper GUI

`piper` provides a GTK UI for configuring the mouse (DPI, LEDs, buttons). Launch from terminal or app menu.

## Reference

- [libratbag GitHub](https://github.com/libratbag/libratbag)
- [libratbag #1853 — Spurious modifier keys](https://github.com/libratbag/libratbag/issues/1853)
- [[software/dev-setup|Dev Setup]]
