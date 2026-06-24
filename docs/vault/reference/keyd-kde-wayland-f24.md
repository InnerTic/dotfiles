# Why F24 worked (keyd + KDE + Wayland)

## 1. keyd is not "typing keys"

keyd acts at the **input device layer**:

```
physical key → kernel input event → virtual keyboard device
```

When you saw `f24 down / up`, keyd successfully injected a synthetic Linux input event.

## 2. The real problem was NOT keyd

Earlier failures (F12/F13/etc.) weren't because remapping failed. They failed because of:

### A) Key collision in KDE
- F12 is often bound to terminal shortcuts, desktop effects, or media layer bindings
- KDE may intercept it before global shortcut handling

### B) Wayland shortcut filtering
On Plasma Wayland, not all synthetic inputs are treated equally for global shortcuts. Some keys get ignored or deprioritized if they are common system keys, already bound in KWin, or come from virtual devices.

## 3. Why F24 specifically worked

F24 succeeds because it has three properties:

- **"Dead space" in the keymap** — rarely used by apps, rarely bound by KDE defaults, no media/system collision
- **Valid Linux input keycode** — kernel supports F1–F24, Wayland recognizes it, KDE shortcut system can bind it
- **Avoids shortcut filtering heuristics** — KDE/Wayland prioritizes real hardware keys and commonly used keys (F1–F12, media keys). F24 is "valid but irrelevant" → passes through cleanly

## 4. The actual pipeline

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
KDE shortcut system sees F24
   ↓
Yakuake binds / toggles
```

## 5. Why earlier "F12 didn't pass through"

Because it likely got intercepted: `keyd → F12 → KDE intercept OR Wayland filter OR existing binding conflict`. It never reached the final shortcut handler in a clean way.

## 6. Core insight

This is not a remapping problem. It is an **input signal routing + shortcut arbitration problem**. Three layers compete:

| Layer   | Role                     |
| ------- | ------------------------ |
| keyd    | generates input          |
| Wayland | filters/normalizes input |
| KDE     | decides shortcut actions |

F24 simply bypasses conflict at the KDE layer.

## 7. Practical rule

> "Never use F1–F12 for synthetic control signals on KDE Wayland if F13–F24 are available"

- F1–F12 = user + app space
- F13–F24 = control plane space

## 8. Known failure: Caps→Hyper→F24 on KDE Wayland

The approach documented above (`capslock = hyper` + `[hyper] space = f24`) **does not work reliably** on KDE Wayland.

### Observed behavior

On both CachyOS and Debian 13 (KDE Plasma 6, Wayland):
- `keyd monitor` shows the virtual keyboard emitting raw `capslock` and `space` — no remapping
- The application receives `Meta+Space`, not F24
- Config file is syntactically valid and loaded correctly

### Why the above theory breaks

The earlier pipeline diagram assumed keyd's layer system would inject F24 into the Wayland event stream. In practice:

```
Caps Lock (held)
   ↓
keyd layer (hyper) ← layer NOT activating
   ↓
maps → F24 ← Not reached — space passes through raw
   ↓
KDE sees Meta+Space ← fallthrough behavior
```

### Suspected causes

- KWin grabs the keyboard device exclusively on Wayland, preventing keyd from intercepting
- The `hyper` layer name is not treated as a modifier by keyd on this build/platform
- Wayland's security model restricts synthetic input from virtual keyboards

### Bottom line

F13–F24 being "control plane space" is correct in theory, but **keyd cannot reliably inject them into KDE Wayland** using layer-based remapping. Alternative approaches needed.

---

## 9. Mental model upgrade

```
F1–F12   = human/UI interaction layer
F13–F24  = system control bus
```

keyd is now acting as a **hardware-to-control-plane compiler**.
