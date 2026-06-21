---
tags: [diagnostics, boot, systemd, troubleshooting]
aliases: [boot-timing, boot-debug, slow-boot]
updated: 2026-06-18
---

# Boot Diagnostics

Commands to identify what's slowing or breaking boot. Organized from overview → detail.

---

## Overview: total boot time

```bash
systemd-analyze time
```

**What it shows:** Total kernel + initramfs + userspace time in seconds.

| Field | What it measures |
|---|---|
| Kernel | Time from power-on to kernel handing off to initramfs |
| Initrd | Time in initramfs (finding root disk, loading storage drivers) |
| Userspace | systemd service startup to reachable desktop |

**Use when:** You want the headline — "boot takes 45s, where is it going?"

---

## Top offenders: per-service breakdown

```bash
systemd-analyze blame | head -20
```

**What it shows:** Each systemd service sorted by startup time (slowest first).

```
5.432s NetworkManager-wait-online.service
3.210s dev-sda1.device
2.100s postgresql.service
```

**Use when:** You need to pinpoint the slowest service. The top 3–5 entries usually account for 80% of boot time.

---

## Boot gaps: failures, timeouts, waits

```bash
journalctl -b | grep -i "timed out\|failed\|waiting\|udev"
```

**What it shows:** systemd log entries for the current boot that indicate:
- **timed out** — a service hit its timeout limit (usually 90s)
- **failed** — a service or unit crashed
- **waiting** — a dependency not yet satisfied (dependency bubble)
- **udev** — device detection events (driver loading, hardware settle)

**Use when:** Boot has a visible pause. This catches the actual error messages most people miss.

---

## Kernel-level delays: hardware negotiation

```bash
dmesg -T | grep -i "delay\|timeout\|firmware"
```

**What it shows:** Kernel ring buffer messages with human timestamps for:
- **delay** — driver waiting for hardware to respond (common: NVMe, USB, network)
- **timeout** — device not responding (disk resets, GPU firmware load)
- **firmware** — firmware loading failures or retries

**Use when:** The pause happens before systemd starts (kernel/initramfs layer), or you see storage/NVMe/GPU stalls.

### Determine which boot layer a message belongs to

| Timestamp position | Layer |
|---|---|
| Before `systemd[1]:` in `journalctl -b` | Kernel or initramfs |
| During initramfs | Between kernel handoff and root mount |
| After `Starting of` messages | systemd userspace |

---

## Critical mental model

Boot has 3 layers, and stalls propagate between them:

| Layer | What happens | How to inspect |
|---|---|---|
| **Kernel** | Hardware detection, drivers, memory init | `dmesg -T` |
| **Initramfs** | Find root disk, prepare mount | `journalctl -b` (early entries) |
| **systemd** | Start services, mount everything, desktop | `systemd-analyze blame` |

**Key insight:** A stall is NOT an error until a timeout is hit. This is why:

| Observation | Likely cause |
|---|---|
| GRUB scanning noise | Harmless, not a stall |
| 20–30s pause | Scheduling sync or hardware negotiation |
| 90–120s pause | A dependency timed out (service not found, disk not ready) |

---

## Script-ready one-liner

```bash
# Quick boot health check — summarize delays in one shot
echo "=== Boot time ===" && systemd-analyze time && echo && echo "=== Top 5 services ===" && systemd-analyze blame | head -5 && echo && echo "=== Failures/timeouts ===" && journalctl -b -p 3 --no-pager | tail -10
```

**What it does:** Prints total boot time, top 5 slowest services, and any errors (priority 3 = error) from current boot — in one command. Suitable for cron, `~/.bashrc` login check, or startup scripts.
