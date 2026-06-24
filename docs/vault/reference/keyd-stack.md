---
tags: [keyd, input, keyboard, remapping]
aliases: [keyd-setup, keyd-debug, keyd-troubleshoot]
updated: 2026-06-18
---

# keyd — Deterministic Debian Stack

Upstream keyd install, diagnostics, and the input group permission fix.

---

## 1. Install from upstream (not distro package)

The Debian/MX package installs a daemon-only build (`/usr/bin/keyd.rvaiya`) missing the CLI tools. Always build from source:

```bash
git clone https://github.com/rvaiya/keyd
cd keyd
make
sudo make install
sudo systemctl enable --now keyd
```

**What you get vs distro package:**

| Component | Distro package | Upstream build |
|---|---|---|
| Daemon (`keyd` service) | ✔ (renamed binary) | ✔ |
| `keyd monitor` | ❌ | ✔ |
| `keyd-application-mapper` | ❌ | ✔ |
| Config reload helpers | ❌ | ✔ |

---

## 2. Verify install

```bash
which keyd                          # should be /usr/local/bin/keyd
keyd monitor                        # if this fails, see section 3
systemctl status keyd               # daemon must be active
```

---

## 3. Permissions: `failed to open /dev/input/eventX`

This is the #1 issue after installing. It means `keyd monitor` cannot read raw input devices.

### 3.1 Add user to input group

```bash
sudo usermod -aG input $USER
```

**You must log out and back in** (or reboot) — group membership does NOT apply to the current session.

### 3.2 Verify

```bash
groups                              # must include 'input'
```

### 3.3 Test

```bash
keyd monitor                        # run without sudo after group fix
```

Expected output: key events appear live. Press keys to verify.

### 3.4 Fallback: udev rule (if group fix alone doesn't work)

```bash
sudo tee /etc/udev/rules.d/99-keyd.rules > /dev/null << 'EOF'
KERNEL=="event*", GROUP="input", MODE="660"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Verify:

```bash
ls -l /dev/input/event0             # expected: crw-rw---- 1 root input
```

---

## 4. Remapping: Caps → Hyper → F24

This does NOT require `keyd monitor` to work — monitor is for debugging only. The remapping itself only needs:

### 4.1 Config file

```bash
sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
*

[main]
capslock = hyper

[hyper]
space = f24
EOF
```

### 4.2 Apply

```bash
sudo systemctl restart keyd
```

---

## 5. Known failure: `capslock = hyper` + `[hyper] space = f24` on KDE Wayland

On this system (and previously on CachyOS), the Caps→Hyper→F24 chain **does not work** with keyd on KDE Wayland.

### What happens

| Step | Expected | Actual |
|---|---|---|
| Hold Caps | `hyper` modifier active | `capslock` passed through unchanged |
| Press Space while holding Caps | `f24` emitted | `space` passed through unchanged |
| Application receives | F24 keypress | Meta+Space (KDE interprets it) |

### Keyd monitor output (virtual keyboard)

```
capslock down
space down
capslock up
space up
```

No remapping occurs — keyd's virtual keyboard emits the raw keys as if no config existed.

### Root cause

Unknown. The same config and keyd version works on other setups. Suspected causes:

| Cause | Why |
|---|---|
| KDE Wayland grabs evdev before keyd | Despite correct permissions, KWin may claim exclusive access |
| `capslock = hyper` syntax mismatch | `hyper` in keyd may need different syntax (e.g. `layer(hyper)`) on some builds |
| Wayland compositor filtering | Synthetic input from keyd's virtual keyboard may be deprioritized by KWin |

### Tested and failed on

- CachyOS (same behavior)
- Debian 13 / MX Linux base (same behavior)
- keyd v2.6.0 (latest upstream)
- KDE Plasma 6, Wayland session

### Practical impact

The Caps→Hyper→F24→Yakuake pipeline cannot be reliably built on KDE Wayland using keyd alone. Alternative approaches are needed (see below).

---

## 6. Debug when mapping "does nothing"

### 5.1 Check if keyd sees the key at all

```bash
keyd monitor                        # press Caps — do you see it?
```

If **yes** (keyd sees it) but mapping fails → KDE/X11/Wayland layer issue.
If **no** → keyd isn't attached to your keyboard device.

### 5.2 Kernel-level input debug (bypasses keyd)

```bash
sudo evtest                         # pick your keyboard, press keys
```

This shows raw evdev events — the ground truth before any remapping layer.

### 5.3 KDE keyboard interception

| Environment | Issue | Fix |
|---|---|---|
| X11 | `setxkbmap` options override | Check `setxkbmap -query` |
| Wayland | KDE keyboard shortcuts layer | Check System Settings → Keyboard → Shortcuts |
| Both | Caps may be grabbed by KDE before keyd | Temporarily disable KDE Caps-binding |

---

## 6. Alternative approaches (when keyd layer remapping fails)

If `capslock = hyper` + `[hyper] space = f24` doesn't produce F24 on your KDE Wayland setup, try these:

### 6.1 Direct key remap (no layer)

Bypass the hyper layer entirely — [[map]] Caps+Space directly to F24:

```bash
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
*

[main]
capslock = compose

[compose]
space = f24
EOF
```

Note: `compose` is a keyd built-in layer name. This may work when custom layer names like `hyper` don't.

### 6.2 Use `layer(hyper)` syntax

```bash
[main]
capslock = layer(hyper)

[hyper]
space = f24
```

The explicit `layer(hyper)` call may be required on some keyd versions instead of bare `hyper`.

### 6.3 Use evdev at the application level

Skip keyd for the F24 binding and instead configure Yakuake (or your target app) to respond to a different signal — e.g., a dbus call or a custom shortcut that doesn't depend on keyd's virtual keyboard layer system.

---

## 7. Quick success check (after reboot)

```bash
groups | grep input                 # must have input group
keyd monitor                        # press Caps Lock → seen?
# Then press Caps + Space → F24 emitted?
```

---

## 7. Key mental model

```
Hardware keypress
  │
  ▼
evdev (/dev/input/event*)    ← keyd reads here (needs input group)
  │
  ▼
keyd daemon                  ← remaps according to /etc/keyd/default.conf
  │
  ▼
KDE/X11/Wayland              ← may re-intercept (shortcuts, layout)
  │
  ▼
Application
```

**Three layers of failure:**

| Layer | Symptom | Debug |
|---|---|---|
| Permission | `keyd monitor` can't open devices | `groups`, `ls -l /dev/input/event0` |
| Config | keyd runs but no remapping | `keyd monitor`, check `/etc/keyd/default.conf` |
| DE intercept | keyd works but KDE overrides | `evtest`, KDE shortcut settings |

---

## 8. Script-ready health check

```bash
echo "=== keyd daemon ===" && systemctl is-active keyd && \
echo "=== groups ===" && groups | grep -o input || echo "MISSING: input group" && \
echo "=== binary ===" && which keyd && \
echo "=== config ===" && cat /etc/keyd/default.conf 2>/dev/null || echo "NO CONFIG"
```
