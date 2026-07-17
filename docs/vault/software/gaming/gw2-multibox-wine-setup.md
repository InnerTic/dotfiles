# GW2 Multi-Box Wine/Proton Setup

> Source: FixBot chat c4c52839 (2026-04-28).

## Architecture

- **2 physical GW2 installs**: one per drive (ssd_storage + nvme-workspace)
- **2 Steam AppIDs**: 1284210 (primary), 2716098372 (second, non-Steam shortcut)
- **Path**: `Z:\workspace\SteamLibrary\steamapps\common\Guild Wars 2\`
- **NVIDIA only**: RTX 3060, integrated AMD GPU causes crashes

## Critical Rules

1. **Z: drive path must exist** — `/workspace` is an nvme mount. All Proton prefixes [[map]] Z: to Linux root. If `/workspace` doesn't resolve, nothing works.
2. **Second account needs an isolated physical copy** — Both instances writing to the same `bin64/cef/` cache causes an ntdll.dll crash (exception 80000100).

## Prefixes

| AppID | Purpose | Location |
|-------|---------|----------|
| 1284210 | Primary GW2 (real Steam AppID) | `/mnt/workspace/SteamLibrary/steamapps/compatdata/1284210/pfx` |
| 2716098372 | Second account | `/home/ken/.local/share/Steam/steamapps/compatdata/2716098372/pfx` |
| 3489019414 | Non-Steam shortcut (defunct) | Was at `/home/ken/.steam/steam/steamapps/compatdata/3489019414/` |
| 2390161803 | Non-Steam shortcut (defunct) | Was at `/home/ken/.local/share/Steam/steamapps/compatdata/2390161803/` |

> **Note:** Only `1284210` is the real Steam AppID. The other IDs are assigned dynamically by Steam when non-Steam shortcuts are added and will change if re-added.

## Normal Behavior

- **Steam log complains about running a non-Steam game** — this is expected when using the 3rd-party addon loader to inject BlishHUD. Ignore it.

## Known Failure Modes

### Launcher stuck at "Initializing" (Local.dat corruption)
GW2's launcher hangs on the splash screen with the spinning logo and never reaches login. This happens when `Local.dat` (settings file in the Wine prefix) grows to 50-80+ MB — should be a few KB. The CEF browser engine can't parse it → never finishes initialization.

**Confirmed cause:** Game auto-patches (Gw2-64.exe update) can corrupt Local.dat on first post-patch launch, especially under Proton/Wine where crash [[QUICK-START]] isn't robust.

**Fix:**
```bash
# For primary prefix (1284210):
cd "/mnt/workspace/SteamLibrary/steamapps/compatdata/1284210/pfx/drive_c/users/steamuser/AppData/Roaming/Guild Wars 2"
mv Local.dat Local.dat.bak

# For secondary prefix (2716098372):
cd "/home/ken/.local/share/Steam/steamapps/compatdata/2716098372/pfx/drive_c/users/steamuser/AppData/Roaming/Guild Wars 2"
mv Local.dat Local.dat.bak

# Also clean up any leftover lock file:
rm -f "/workspace/SteamLibrary/steamapps/common/Guild Wars 2/Gw2-64.tmp"
```

GW2 will recreate Local.dat with defaults on next launch. Graphics/sound settings will reset.

**References:** This is a well-known issue on both Windows and Linux — documented on Steam forums, Reddit, and GW2 support threads since at least 2015. Fix applies identically under Proton/Wine.

### "File not found" (Os { code: 2, kind: NotFound })
Loader can't find `Gw2-64.exe`. Causes:
- Wrong working directory
- Case sensitivity (Linux is case-sensitive, GW2 is not)
- Broken Z: drive path — ensure `/workspace` exists

### Mono incompatible / dotnet required
One of the initial setup steps (either adding `Gw2-64.exe` or the addon loader first) triggers a mono incompatibility error. Fix:
```bash
WINEPREFIX="$PREFIX" protontricks $APPID dotnet48
```
The exact order that avoids this still needs to be documented — see test build notes below.

### libEGL warnings (pci id 10de:2504, driver null)
Wine can't initialize the NVIDIA 3D surface. Fix:
```bash
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
```

## Setup

Launch GW2 once via Steam. Let Vulkan populate. Fully log into the game once, then exit — this installs the default Wine prefix.

In Steam, add a non-Steam game pointing to `/workspace/SteamLibrary/steamapps/common/Guild Wars 2/Gw2-64.exe`. Fully load the client and log in to fill the prefix. Then add another non-Steam game pointing to the loader at `.../addons/LOADER_public/Gw2-Simple-Addon-Loader.exe`. Set everything to GE-Proton10-32 — it works with both GW2 and the loader.

On the desktop, create a link to the addon loader on each drive for each account. Double-click either drive's launcher. Protontricks runs as default and picks up the Steam prefix. Either prefix works with either addon loader. BlishHUD launches with whichever loads first.

The addon loader can launch this way without needing Steam running. Steam won't launch both accounts at the same time, so launch at least one manually and one through Steam.

## Launch Option in Steam

Set launch option to: `-provider Portal`

This tells GW2 to use ArenaNet login instead of Steam login. Required for all accounts launched through Steam. Once the prefixes are set up, you can load directly from the desktop shortcuts and bypass Steam entirely.

## Clean Rebuild

1. Delete the prefix: `rm -rf $PREFIX`
2. Launch the game once via Steam to recreate the prefix structure
3. Install deps: `WINEPREFIX="$PREFIX" protontricks $APPID corefonts dxvk`
4. Launch with NVIDIA force flags
5. If still crashing, disable the overlay DLL: `mv external_dx11_overlay.dll external_dx11_overlay.dll.bak`
6. Clear the NVIDIA shader cache: `rm -rf ~/.nv/GLCache`

## Notes

- GE-Proton10-32 was the working version. Wine 11.7 had regressions.
- Steam library paths in `libraryfolders.vdf` must point to actual mount points (not auto-mount paths).

## Test Build Investigation

Document exact setup order on a clean test build. Run a 2B or 4B local model to monitor Steam logs + GW2 addon logs and determine the correct sequence that avoids the mono/dotnet issue.

First fork will be on this build.
