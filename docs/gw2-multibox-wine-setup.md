# GW2 Multi-Box Wine/Proton Setup (Distilled)

> Source: FixBot chat c4c52839 (2026-04-28). Full log: `fixbot.ifixit.comchatc4c528.txt`

## Architecture

- **2 physical GW2 installs**: one per drive (ssd_storage + nvme-workspace)
- **2 Steam AppIDs**: 1284210 (primary), 2716098372 (second, non-Steam shortcut)
- **Path**: `Z:\workspace\SteamLibrary\steamapps\common\Guild Wars 2\`
- **NVIDIA only**: RTX 3060, integrated AMD GPU causes crashes

## Critical Rules (Don't Break These)

1. **Z: drive path must exist** — `/workspace` → nvme mount. All Proton prefixes map Z: to Linux root. If `/workspace` doesn't resolve, everything breaks.
2. **Second account needs isolated physical copy** — Both instances writing to the same `bin64/cef/` cache = ntdll.dll crash (exception 80000100).

## Prefixes

| AppID | Purpose | Location |
|-------|---------|----------|
| 1284210 | Primary GW2 | `/mnt/workspace/SteamLibrary/steamapps/compatdata/1284210/pfx` |
| 2716098372 | Second account | `/home/ken/.local/share/Steam/steamapps/compatdata/2716098372/pfx` |
| 3489019414 | Non-Steam shortcut (defunct) | Was at `/home/ken/.steam/steam/steamapps/compatdata/3489019414/` |
| 2390161803 | Non-Steam shortcut (defunct) | Was at `/home/ken/.local/share/Steam/steamapps/compatdata/2390161803/` |

## Known Failure Modes

### "File not found" (Os { code: 2, kind: NotFound })
Loader can't find `Gw2-64.exe`. Causes:
- Wrong working directory
- Case sensitivity (Linux is case-sensitive, GW2 is not)
- Broken Z: drive path → fix: ensure `/workspace` exists


Prefix is incomplete/corrupted. Fix:
```bash
WINEPREFIX="$PREFIX" protontricks $APPID corefonts dxvk
```

### libEGL warnings (pci id 10de:2504, driver null)
Wine can't initialize NVIDIA 3D surface. Fix:
```bash
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
```

## Launch Commands

### Primary account (via Steam)
Launch normally from Steam library.
Let Vulkan populate. Fully log into the game once. exit
default wine prefix is installed.
In steam, add a non-steam game /workspace/SteamLibrary/steamapps/common/Guild Wars 2/Gw2-64.exe
fully load the client login to fill the prefix.
the add non steam game again, this time the loader /workspace/SteamLibrary/steamapps/common/Guild Wars 2/addons/LOADER_public/Gw2-Simple-Addon-Loader.exe
set everything to protonGE10-32 it works with gw2 and with the loader.
on the Desktop create a link to file, point it at the addon loader, on each drive for 2 acounts.
double click the either drive launcher. protontricks launcher as default. bings up steam prefixes. either steam prefix can used with either addon_loader.  blishhud lauches witht e first to be loaded.
the addon loader can be launched this way without having to launch steam client. steam wont launch both acounts at the same time so at least one is launched this manual way one launched through steam.

## Clean Rebuild Procedure

1. Delete prefix: `rm -rf $PREFIX`
2. Launch game once via Steam to recreate prefix structure
3. Install dependencies: `WINEPREFIX="$PREFIX" protontricks $APPID corefonts dxvk`
4. Launch with NVIDIA force flags (see above)
5. If crashing, disable overlay DLL: `mv external_dx11_overlay.dll external_dx11_overlay.dll.bak`
6. Clear NVIDIA shader cache: `rm -rf ~/.nv/GLCache`

## Notes

- GE-Proton10-32 was the working version. Wine 11.7 had regressions.
- Steam library paths in `libraryfolders.vdf` must point to actual mount points (not auto-mount paths).
- The `-shareArchive` flag is needed for multi-boxing to allow shared Gw2.dat access.
