---
title: CoolerControl
tags:
  - software
  - system
  - cooling
  - fans
---

# CoolerControl

Fan control for Linux — monitors and controls cooling devices (CPU, GPU, case fans).

## Installation

**CachyOS** (from CachyOS repo, builds from source):

```bash
sudo pacman -S coolercontrol
```

**Alternative** (binary package from AUR):

```bash
yay -S coolercontrol-bin
```

Both pull in `coolercontrold` as a dependency.

## Service

The daemon must be running for the GUI to work:

```bash
sudo systemctl enable --now coolercontrold
```

## Usage

- Launch: `coolercontrol` (GUI)
- Profiles saved at `/etc/coolercontrol/`
- The daemon (`coolercontrold`) applies profiles on boot

## Reference

- [Homepage](https://gitlab.com/coolercontrol/coolercontrol)
- [[software/dev-setup|Dev Setup]]
