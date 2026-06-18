# Yakuake Toggle via keyd + F24 on KDE Wayland

Why F24 works for Yakuake's keyboard shortcut where F12 doesn't.

## The problem

Yakuake defaults to F12 for drop-down toggle. On KDE Wayland, F12 is often intercepted by KDE (terminal shortcuts, desktop effects, media bindings) before Yakuake sees it. Even keyd-generated F12 signals get filtered by Wayland's shortcut arbitration.

## The fix

Remap a dead key (Caps Lock as Hyper) → F24 via keyd, then set Yakuake's toggle shortcut to F24.

## Why F24 works

F24 is "dead space" — rarely used by apps, rarely bound by KDE defaults, no media/system collision. KDE/Wayland's shortcut filtering prioritizes real hardware keys and common keys (F1–F12). F24 is "valid but irrelevant" so it passes through cleanly.

## Pipeline

```
Caps Lock (held)
   ↓
keyd layer (hyper)
   ↓
maps → F24
   ↓
virtual keyboard device emits event
   ↓
Wayland accepts event
   ↓
KDE shortcut system sees F24 (no conflict)
   ↓
Yakuake binds / toggles
```

## Key insight

This is not a remapping problem. It is an input signal routing + shortcut arbitration problem across three layers: keyd (generates input) → Wayland (filters/normalizes) → KDE (decides shortcuts). F24 bypasses conflict at the KDE layer because nothing else claims it.

## Rule for KDE Wayland

Never use F1–F12 for synthetic control signals if F13–F24 are available. F1–F12 = user+app space; F13–F24 = control plane space.
