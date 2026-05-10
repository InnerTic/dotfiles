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
3. **Force NVIDIA GPU** — Always set `__NV_PRIME_RENDER_OFFLOAD=1` and `__GLX_VENDOR_LIBRARY_NAME=nvidia`. Without it, Wine picks the AMD iGPU which can't handle GW2's Vulkan/DX11.
4. **Strip LD_PRELOAD** — Steam overlay DLLs (`gameoverlayrenderer.so`) cause ELFCLASS32/64 errors. Set `LD_PRELOAD=""`.

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

### ntdll.dll crash (exception 80000100)
Loader overlay DLL conflicts with Wine's d3d11. Fixes (in order):
1. Isolate second install on separate drive
2. Disable `external_dx11_overlay.dll` (rename to `.bak`)
3. Clear CEF cache: `rm -rf "$PREFIX/drive_c/users/ken/AppData/Local/Guild Wars 2/cache"`

### Mono installer prompt
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

### Second account (via protontricks)
```bash
export MY_PREFIX="/home/ken/.local/share/Steam/steamapps/compatdata/2716098372/pfx"
env WINEPREFIX="$MY_PREFIX" \
    __NV_PRIME_RENDER_OFFLOAD=1 \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    LD_PRELOAD="" \
    protontricks 2716098372 run "C:\addons\LOADER_public\Gw2-Simple-Addon-Loader.exe"
```

### Second account (direct wine, bypassing protontricks)
```bash
env WINEPREFIX="$MY_PREFIX" \
    __NV_PRIME_RENDER_OFFLOAD=1 \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    wine "Z:/workspace/SteamLibrary/steamapps/common/Guild Wars 2/addons/LOADER_public/Gw2-Simple-Addon-Loader.exe"
```

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
