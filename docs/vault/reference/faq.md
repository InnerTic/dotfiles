---
tags: [reference, faq]
aliases: [faq, common-questions]
updated: 2026-06-15
---

# Frequently Asked Questions

## Models & AI

**Q: Where do my models live?**

All GGUF model files are in `~/Downloads/llm_models/`. The `llm` alias lists them
interactively and starts [[llama-server]] with your pick. `~/Models` is a symlink for
quick access.

**Q: How do I switch models?**

Run `llm` to see the menu, pick a number. This updates
`~/.config/opencode/opencode.json` with the selected model and restarts
[[llama-server]]. In OpenCode TUI, use `/model llama.cpp/<filename>`.

**Q: Why two GPUs? How do I pick which one to use?**

RTX 3060 (12GB) for small models and SD image gen. Tesla P40 (24GB) for large
quantized LLMs. Set `CUDA_VISIBLE_DEVICES=0` for the 3060, `=1` for the P40.
See [[gpu/gpu-config-notes]] for the full setup.

**Q: llama.cpp won't run / falls back to CPU?**

Usually a stale CUDA library path. Run `sudo ldconfig` to rebuild the linker
cache, or check that `LD_LIBRARY_PATH` includes `/opt/cuda/lib64`.
See [[gpu/gpu-config-notes]] for the full fix walkthrough.

## System & Storage

**Q: What happens to my files when I reinstall the OS?**

- `/mnt/workspace` (nvme) — untouched, holds everything important
- `/mnt/ssd_storage` (sdb) — untouched, bind-mounted media dirs
- `/home` (sdd) — wiped, but 6 critical dirs are symlinked to workspace
- `/` (sda) — wiped, fresh OS

After reinstall, run `link-workspace.sh --apply` → `bootstrap.sh` and you're back.
See [[QUICK-START]] for the 5-minute [[QUICK-START]].

**Q: What exactly persists across an OS wipe?**

Only 6 things are symlinked from `/home` to `/mnt/workspace`:
`.ssh`, `.librewolf`, `.openclaw`, `.opencode`, `dotfiles`, `openclaw`.
Everything else (`.cache`, `.config/*`, `.steam`, etc.) regenerates on first use.
See [[reference/workspace-symlink-strategy]] for the full rationale.

**Q: Which drive should I use for what?**

| What | Drive | Mount |
|------|-------|-------|
| AI models, projects | nvme (fastest) | `/mnt/workspace` |
| Documents, media | SSD | `/mnt/ssd_storage` |
| Long-term backup | HDD (largest) | `/mnt/data` |
| VMs | sde3 | `/mnt/vm-disks` |
| MX Linux (secondary OS) | sde2 | rootMX25 (ext4) |
| Configs, caches | sdd | `/home` (ephemeral) |

**Q: My /home is on a small drive and fills up. What do?**

`/home` is 112G. The big items (Downloads, Documents, Pictures, Videos, Music,
Desktop, go, MEGA) are bind-mounted from `/mnt/ssd_storage` (465G). Check
`~/Downloads/Downloads` — sometimes things download to the wrong folder
if the bind mount hasn't been set up yet.

## Gaming

**Q: Guild Wars 2 multi-box setup?**

Two physical installs on separate [[drives-and-mounts]], two Steam AppIDs (1284210 and
2716098372), separate Proton prefixes. See [[gaming/gw2-multibox-wine-setup]].

**Q: Game won't start / Proton issue?**

Check the Wine prefix isn't corrupted. Try `protontricks <appid> --verbose`.
GW2 `Local.dat` file in the prefix can block the launcher — delete it to reset
settings.

## Hardware

**Q: Tesla P40 not detected?**

Check the kernel cmdline includes `nvidia.NVreg_EnablePCIeGen3=1`. The P40
needs PCIe Gen3 forced on some boards. Also verify Above 4G Decoding is
enabled in BIOS. See [[gpu/tesla-p40-vfio-passthrough]].

**Q: Why is the P40 bound to vfio-pci instead of nvidia?**

The P40 is passed through to a VM for AI workloads. The `nvidia` driver
is used by the RTX 3060 for the host. They can't both use the same driver
when one is passed through. See [[gpu/gpu-config-notes]].

## Network

**Q: What are my network IPs?**

| Host | IP | Purpose |
|------|----|---------|
| Akuma (this PC) | `172.16.5.1` | Desktop |
| ZimaBoard | `172.16.1.1` | DNS/Unbound |
| pihole | `172.16.12.1` | Ad-blocking DNS |
| MikroTik | `172.16.88.1` | Switch/router |

**Q: How do I SSH into other machines?**

SSH config at `~/.ssh/config` defines shortcuts:
- `ssh zima` → ZimaBoard
- `ssh pihole` → pihole LXC
- `ssh mikrotik` → MikroTik switch

Keys are persisted via workspace symlink.

## Related

- [[system/drives-and-mounts]] — Drive UUIDs, [[drives-and-mounts]], bind [[drives-and-mounts]]
- [[gpu/gpu-config-notes]] — Dual-GPU setup and troubleshooting
- [[reference/workspace-symlink-strategy]] — Persistence strategy
- [[QUICK-START]] — [[QUICK-START]] [[QUICK-START]] guide
