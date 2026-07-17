---
tags: [system, recovery, limine, dual-boot]
aliases: [limine-recovery, mx-recovery, boot-recovery]
updated: 2026-06-18
---

# Dual-Boot Recovery — Limine / MX Linux

Clean [[QUICK-START]] path when the MX Linux entry breaks in Limine.
No assumptions, no dependency on a working GUI.

## Scenario: MX entry in Limine breaks

**Symptoms:**

- MX option disappears from Limine menu
- or selecting it returns you to Limine

This only affects Limine, not the system.

---

## Level 1 — Immediate recovery (inside Limine config)

Boot into CachyOS (or whichever still works).

**Step 1: open config**
```bash
sudo nano /boot/limine.conf
```

**Step 2: remove ONLY this block**

Delete:
```
MX Linux {
    protocol: efi
    path: boot():/EFI/MX/shimx64.efi
}
```

Make sure you remove the whole block, nothing else.

**Step 3: save + exit**
- `CTRL + O` (save)
- `ENTER`
- `CTRL + X` (exit)

**Step 4: reboot**
```bash
reboot
```

MX is now gone from Limine menu. CachyOS still boots normally.

---

## Level 2 — If you cannot boot CachyOS via Limine

Fallback chain.

**Step 1: use firmware boot menu**

Press at startup: `F12` / `ESC` / `DEL` (varies by board)

Select:
```
MX Linux
```

This uses `\EFI\MX\shimx64.efi`.

**Step 2: boot into MX directly**

Once inside MX, fix Limine config on Cachy disk:

```bash
lsblk
```

Find Cachy root, then:
```bash
sudo mount /dev/sdX2 /mnt
sudo nano /mnt/boot/limine.conf
```

Remove MX block as above.

---

## Level 3 — If Limine itself is broken (rare)

If Limine does not show at all:

**Step 1: boot MX via firmware**

Select:
```
MX Linux (Boot0002)
```

**Step 2: restore Limine boot entry**

Check entries:
```bash
sudo efibootmgr -v
```

Reorder so Limine is first:
```bash
sudo efibootmgr -o 0000,0002,0003,0006
```

---

## Level 4 — Absolute fallback (UEFI emergency path)

If everything is confused:

Use:
```
UEFI OS
```

That points to `\EFI\BOOT\BOOTX64.EFI`. This is your failsafe loader.

---

## Key idea (important mental model)

You are NOT breaking the system if Limine entry fails.
You are only breaking "a menu entry inside Limine."

Everything else remains independent:

| Layer        | Survival |
|--------------|----------|
| UEFI firmware | always  |
| MX shim      | always   |
| Limine       | removable layer |
| OS installs  | untouched |

---

## Minimal recovery cheat sheet

```bash
# If MX breaks in Limine:
sudo nano /boot/limine.conf
# delete MX block
reboot

# If system won't boot:
# boot firmware menu -> MX Linux

# If Limine is missing:
sudo efibootmgr -o 0000,0002,0003,0006
```

## Related

- [[QUICK-START]] — [[QUICK-START]] [[QUICK-START]] (full reinstall)
- [[system/drives-and-mounts]] — Drive layout, UUIDs, [[drives-and-mounts]]
- [[reference/bugs-and-workarounds]] — Active upstream [[bugs-and-workarounds]]
