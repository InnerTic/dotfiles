---
tags: [reference, glossary, definitions]
aliases: [glossary, definitions, terms, abbreviations]
updated: 2026-06-15
---

# Glossary & Abbreviations

## System & Infrastructure

**Workspace** — `/mnt/workspace`, a separate NVMe drive (465GB, ext4) that persists across OS wipes. Never gets formatted. Holds dotfiles, models, projects.

**NVME-workspace** — UUID `9a1cdd8a-3d81-468f-be70-aa00a01d7301`, the physical drive mounted at `/mnt/workspace`.

**Bind mount** — A Linux filesystem feature that mounts one location inside another without copying. Example: `/mnt/ssd_storage/ken/Documents` mounted at `~/Documents`. Used for media directories.

**Symlink** — A shortcut pointing from one path to another. Example: `~/.ssh → /mnt/workspace/.ssh`. Used to persist configs from workspace into home.

**Bootstrap** — The `bootstrap.sh` script that creates shell config (`.zshrc`), git config (`.gitconfig`), and other dotfiles on a fresh system.

---

## AI & Machine Learning

**llama.cpp** — C++ implementation of LLaMA inference, GPU-accelerated via CUDA. Runs `.gguf` model files.

**GGUF** — Quantized model format ("GPT-Generated Unified Format"). Smaller, faster than full FP32 models. Example: `Qwen2.5-7B-Q5_K_M.gguf` (7 billion parameters, Q5 quantization).

**Quantization** — Reducing model precision (FP32 → FP16 → INT8 → INT4) to fit more in VRAM and run faster. Q5 = ~5 bits per weight, good balance of speed/quality.

**OpenCode** — A TUI/Web AI tool that manages models and runs inference. Supports local llama.cpp + cloud providers (OpenRouter, etc.).

**TextGen WebUI** — Web interface for text generation, similar to OpenCode but browser-based.

**Forge** — Stable Diffusion WebUI (image generation). Runs on port 7860.

**SDXL** — Stable Diffusion XL, improved image model. Commonly used in Forge.

**ngl** — "number of GPU layers". Flag for llama-server: `-ngl 35` means offload 35 transformer layers to GPU, rest to CPU.

**KV cache** — "Key-Value cache", intermediate tensors that speed up inference. Usually lives in VRAM; with `--no-kv-offload` it lives in system RAM (saves VRAM).

---

## GPU & CUDA

**CUDA** — Nvidia's parallel computing API. llama.cpp uses it for GPU acceleration.

**sm_61 / sm_86** — "Streaming Multiprocessor" architectures. sm_61 = Pascal (Tesla P40), sm_86 = Ampere (RTX 3060). Both can run in same binary if compiled with both targets.

**RTX 3060** — Consumer GPU, 12GB VRAM, Ampere arch (sm_86). Used for gaming, SD WebUI, small models.

**Tesla P40** — Datacenter GPU, 24GB VRAM, Pascal arch (sm_61). Used for large quantized LLMs via llama.cpp.

**nvidia-smi** — Nvidia System Management Interface. Shows GPU info, VRAM usage, temperatures.

**CUDA_VISIBLE_DEVICES** — Environment variable that selects which GPU to use. `0` = first GPU, `1` = second, etc.

**LD_LIBRARY_PATH** — Linker search path for `.so` files. llama-server needs `/opt/cuda/lib64` on the path to find CUDA libraries at runtime.

---

## Wine / Gaming

**Wine** — Windows compatibility layer for Linux. Translates Windows API calls to Linux equivalents.

**Proton** — Valve's Wine fork with DirectX/Vulkan support. Used by Steam for Windows games on Linux.

**WINEPREFIX** — Directory containing a virtual C: drive. Each game gets its own prefix to avoid conflicts. Example: `/mnt/workspace/SteamLibrary/steamapps/compatdata/1284210/pfx`.

**DXVK** — DirectX 9-12 to Vulkan translation layer. Installed in Wine prefixes to enable graphics.

**BlishHUD** — Guild Wars 2 addon loader and HUD overlay.

**GW2** — Guild Wars 2, MMORPG. Multibox setup uses 2 Wine prefixes on separate drives.

**AppID** — Steam application ID. GW2 is `1284210`. Non-Steam shortcuts get dynamic IDs like `2716098372`.

---

## Virtualization & Hardware

**VFIO** — "Virtual Function I/O". Lets you pass a physical GPU (or other PCIe device) directly to a virtual machine. The P40 can be isolated this way for AI workloads in VMs.

**IOMMU** — "Input/Output Memory Management Unit". CPU feature (Intel VT-d, AMD-Vi) required for VFIO. Must be enabled in BIOS.

**vfio-pci** — Kernel driver that binds a PCIe device for VFIO passthrough instead of letting the normal driver manage it.

**PCI ID** — Format: `VENDOR:DEVICE`. Example: RTX 3060 is `10de:2504` (10de = Nvidia, 2504 = GA106). Used to identify hardware.

**Above 4G Decoding** — BIOS setting that enables PCIe devices to use memory above 4GB. Required for Tesla P40 to POST.

**CSM** — "Compatibility Support Module". Legacy BIOS mode. Modern setups use UEFI only (CSM disabled).

---

## Network & Infrastructure

**Akuma** — This PC (hostname). IP: `172.16.5.1`.

**ZimaBoard** — DNS + Unbound server on the network. IP: `172.16.1.1`.

**pihole** — Ad-blocking DNS on LXC container. IP: `172.16.12.1`.

**MikroTik** — Network switch. IP: `172.16.88.1`.

**SSH config** — `~/.ssh/config` defines shortcuts like `ssh zima`, `ssh pihole`, etc. Persisted via symlink to workspace.

---

## Files & Storage

**`.gguf`** — Model file format (llama.cpp). Lives in `~/Downloads/llm_models/`.

**`Local.dat`** — Guild Wars 2 settings file (Wine prefix). Can corrupt and block launcher; workaround in [[software/gaming/gw2-wine]].

**`fstab`** — Linux filesystem table. Defines bind mounts and drive mounts at boot. See [[system/drives-and-mounts]].

**UUID** — Universally Unique Identifier for drives. Used in fstab instead of device names (which can change). Example: `UUID=9a1cdd8a-3d81-468f-be70-aa00a01d7301`.

---

## Processes & Tools

**pkill** — Kill processes by name. Example: `pkill -f llama-server` kills all processes matching "llama-server".

**rsync** — Intelligent file sync. `rsync -a` copies preserving permissions/timestamps. Used in [[scripts/link-workspace.sh]] to merge directories.

**curl** — HTTP client. Used to test llama.cpp API: `curl http://127.0.0.1:8080/v1/models`.

**jq** — JSON query tool. Parse API responses: `curl ... | jq -r .data[].id` extracts model names.

**CMake** — Build system. Used to build llama.cpp with CUDA support.

**nvcc** — Nvidia CUDA compiler. Compiles GPU kernels for specific architectures (sm_61, sm_86).

**mkinitcpio** — Generate Linux initramfs. Used after kernel parameter changes (VFIO, etc.) to rebuild boot.

---

## Abbreviations

| Abbr | Meaning |
|------|----------|
| **AI** | Artificial Intelligence |
| **CUDA** | Compute Unified Device Architecture (Nvidia) |
| **GPU** | Graphics Processing Unit |
| **CPU** | Central Processing Unit |
| **VRAM** | Video RAM (on GPU) |
| **IOMMU** | Input/Output Memory Management Unit |
| **PCIe** | PCI Express (hardware bus) |
| **BIOS** | Basic Input/Output System |
| **UUID** | Universally Unique Identifier |
| **TUI** | Terminal User Interface |
| **WebUI** | Web User Interface |
| **API** | Application Programming Interface |
| **MMORPG** | Massively Multiplayer Online Role-Playing Game |
| **VPS** | Virtual Private Server |
| **LXC** | Linux Containers |
| **VM** | Virtual Machine |
| **SSH** | Secure Shell |
| **DNS** | Domain Name System |
| **UEFI** | Unified Extensible Firmware Interface |
| **FP32/FP16/INT8** | Floating Point 32/16-bit, Integer 8-bit (precision levels) |
