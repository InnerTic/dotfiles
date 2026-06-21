# Conky System Cockpit — Unified Telemetry HUD

A persistent system telemetry instrument cluster for a multi-GPU compute node.

## Core Philosophy

One consistent visual grammar across CPU / RAM / GPU / NET so the whole thing reads like a single machine, not four unrelated panels.

---

## The Cockpit Grammar

Every subsystem uses the same 4-line structure:

```
[NAME + ID]
STATE LINE
METRIC LINE 1
METRIC LINE 2
```

Optional 5th line: graphs

### Visual Language

| Rule | Example |
|------|---------|
| Labels are ALWAYS uppercase 4-6 chars | `CPU`, `MEM`, `GPU0`, `GPU1`, `NET` |
| vertical bars = instantaneous metrics | `51°C \| 15% \| 18W` |
| slash = capacity | `1119/12288 MB` |
| parentheses = derived state | `(10786 free)` |

---

## System Header

```
SYSTEM
STATE: OK | UP ${uptime_short}
OS: ${sysname} ${kernel}
TIME: ${time %a %d %b %H:%M}
```

---

## CPU Core

```
CPU
LOAD ${cpu}% | FREQ ${freq_g cpu0}GHz

CORE0 ${cpu cpu0}% ${cpubar cpu0}
CORE1 ${cpu cpu1}% ${cpubar cpu1}
CORE2 ${cpu cpu2}% ${cpubar cpu2}
CORE3 ${cpu cpu3}% ${cpubar cpu3}
```

---

## Memory

```
MEM
USED ${mem}/${memmax} (${memperc}%)
FREE ${memeasyfree}
CACHE ${cached} | BUFF ${buffers}

TOP RAM
${top_mem name 1} ${top_mem mem 1}%
${top_mem name 2} ${top_mem mem 2}%
${top_mem name 3} ${top_mem mem 3}%
```

---

## GPU Blocks (Unified Format)

Both GPU0 and GPU1 use identical structure:

```
GPU0 RTX 3060
STATE ${execi 5 nvidia-smi --id=0 --query-gpu=pstate --format=csv,noheader}

PERF  ${execi 5 nvidia-smi --id=0 --query-gpu=temperature.gpu,utilization.gpu,power.draw,power.limit --format=csv,noheader | awk -F, '{printf "%s°C | %s%% | %sW/%sW",$1,$2,$3,$4}'}

MEM   ${execi 5 nvidia-smi --id=0 --query-gpu=memory.used,memory.total --format=csv,noheader | awk -F, '{printf "%s/%s MB",$1,$2}'}

CLK   ${execi 5 nvidia-smi --id=0 --query-gpu=clocks.current.graphics,clocks.max.graphics --format=csv,noheader | awk -F, '{printf "%s/%s MHz",$1,$2}'}

BUS   PCIe Gen${execi 5 nvidia-smi --id=0 --query-gpu=pcie.link.gen.current --format=csv,noheader} x${execi 5 nvidia-smi --id=0 --query-gpu=pcie.link.width.current --format=csv,noheader}
```

```
GPU1 Tesla P40
STATE ...
PERF  ...
MEM   ...
CLK   ...
BUS   ...
```

---

## Network

Live interface matrix, no conditional branching:

```
NET
ETH ${addr eth0}
RX  ${downspeedf eth0} kB/s | TX ${upspeedf eth0} kB/s
TOT ${totaldown eth0} / ${totalup eth0}

WIFI ${wireless_essid wlan0}
SIGN ${wireless_link_bar wlan0}
RX   ${downspeedf wlan0} kB/s | TX ${upspeedf wlan0} kB/s
```

---

## Disk

```
DISK
ROOT ${fs_used /}/${fs_size /} ${fs_bar /}
SSD  ${fs_used /mnt/ssd_storage}/${fs_size /mnt/ssd_storage}
NVME ${fs_used /mnt/workspace}/${fs_size /mnt/workspace}
DATA ${fs_used /mnt/data}/${fs_size /mnt/data}
M2   ${fs_used /mnt/m2_storage}/${fs_size /mnt/m2_storage}
```

---

## Why This Works

1. **Cognitive uniformity** — every subsystem speaks the same language
2. **Dense but scannable** — data is standardized, not reduced
3. **GPU panels feel integrated** — just another instrument in the system
4. **Conky becomes a background OS dashboard** — not a script or widget

---

## Telemetry Abstraction Layer (Future)

- Define a Conky macro system (pseudo-templates)
- Unify all `execi` calls into grouped queries
- Reduce NVML calls by batching per GPU
