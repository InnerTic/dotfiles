---
title: LibreWolf
tags:
  - software
  - browser
  - librewolf
  - privacy
---

# LibreWolf

Privacy-hardened Firefox fork installed on both Debian and CachyOS.

## Installation

**CachyOS** (`librewolf-bin` from AUR via CachyOS repo):

```bash
sudo pacman -S librewolf-bin
```

**Debian** (from upstream .deb repo):

```bash
# Per https://librewolf.net/installation/debian/
curl -fsSL https://rpm.librewolf.net/librewolf.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/librewolf.gpg] https://rpm.librewolf.net/debian bookworm main" | sudo tee /etc/apt/sources.list.d/librewolf.sources
sudo apt update && sudo apt install librewolf -y
```

## Profile

The primary profile is `coy0vc1u.ken` at `~/.librewolf/coy0vc1u.ken/`.

| Profile | Path | Purpose |
|---------|------|---------|
| `ken` | `coy0vc1u.ken` | Primary daily driver |

### Version mismatch

If LibreWolf warns about an "older version" launching with an existing profile, the profile's `compatibility.ini` contains a `LastVersion` newer than the installed package. Fix:

```bash
# Copy the build ID from a freshly-created default profile:
grep LastVersion ~/.librewolf/*.default-default/compatibility.ini
# Update the offending profile:
sed -i 's/LastVersion=.*/LastVersion=151.0.4-1_20260609182557\/20260609182557/' ~/.librewolf/coy0vc1u.ken/compatibility.ini
```

## Overrides

Configuration is managed through `~/.librewolf/librewolf.overrides.cfg`. See the [official docs](https://www.librewolf.net/docs/settings/) for available options.

Current overrides (captured from `coy0vc1u.ken` profile):

| Category | Setting | Value |
|----------|---------|-------|
| Fingerprinting | `privacy.resistFingerprinting` | `false` (uses `fingerprintingProtection` instead) |
| | `privacy.fingerprintingProtection` | `true` |
| Tracking | `privacy.trackingprotection.enabled` | `true` |
| | `privacy.trackingprotection.socialtracking.enabled` | `true` |
| | `privacy.trackingprotection.emailtracking.enabled` | `true` |
| | `privacy.bounceTrackingProtection.mode` | `1` |
| | `privacy.query_stripping.enabled` | `true` |
| Content blocking | `browser.contentblocking.category` | `"strict"` |
| Referer | `network.http.referer.XOriginPolicy` | `2` |
| Network | `network.http.speculative-parallel-limit` | `0` |
| | `network.prefetch-next` | `false` |
| | `network.captive-portal-service.enabled` | `false` |
| | `network.connectivity-service.enabled` | `false` |
| | `network.http.http3.enable_0rtt` | `false` |
| | `security.tls.enable_0rtt_data` | `false` |
| Safe Browsing | `browser.safebrowsing.downloads.remote.enabled` | `false` |
| HTTPS | `dom.security.https_only_mode` | `false` (PBM only) |
| | `dom.security.https_only_mode_ever_enabled_pbm` | `true` |
| Sync | `identity.fxaccounts.enabled` | `true` |
| Media | `media.eme.enabled` | `true` (Widevine DRM) |
| Session | `browser.startup.page` | `3` (restore previous) |
| Autoscroll | `general.autoScroll` | `true` |
| | `middlemouse.paste` | `false` |
| Forms | `signon.rememberSignons` | `true` |
| | `extensions.formautofill.addresses.enabled` | `true` |
| Search | Default engine | DuckDuckGo |
| UI | Theme | Firefox Compact Dark |
| | `browser.tabs.inTitlebar` | `1` |

## Extensions installed

| Extension | ID |
|-----------|-----|
| uBlock Origin | `uBlock0@raymondhill.net` |
| Dark Reader | `addon@darkreader.org` |
| Tabby (container tabs) | `tabby@whatsyouridea.com` |
| LibreTranslate | `LibreTranslate@Indogermane` |
| Plasma Browser Integration | `plasma-browser-integration@kde.org` |

## Extensions

Managed manually. Recommended:

- uBlock Origin
- Bitwarden

## Local SearXNG

A custom `policies.json` adds the local SearXNG instance as a search engine:

| Setting | Value |
|---------|-------|
| Name | SearXNG (local) |
| URL | `http://172.16.12.16:8888/search?q={searchTerms}` |
| Suggest | `http://172.16.12.16:8888/autocompleter?q={searchTerms}` |

**Deployment**: Custom policies live at `~/dotfiles/librewolf/policies.json` (mirror of LibreWolf defaults + SearXNG addition). A pacman hook at `/etc/pacman.d/hooks/librewolf-policies.hook` redeploys after every `librewolf-bin` update so it survives upgrades.

To trigger manually:
```bash
sudo cp ~/dotfiles/librewolf/policies.json /usr/lib/librewolf/distribution/policies.json
```

## How it works

| Mechanism | File | Scope |
|-----------|------|-------|
| `librewolf.overrides.cfg` | `~/.librewolf/librewolf.overrides.cfg` | Preferences (prefs, via `defaultPref()`). Read on every startup. |
| `policies.json` | `/usr/lib/librewolf/distribution/policies.json` | Search engines, extensions, updates. Managed by pacman hook. |
| `compatibility.ini` | `~/.librewolf/<profile>/compatibility.ini` | Profile version. Fix after LibreWolf version mismatch. |

The overrides file uses `defaultPref()` — sets defaults that the user can still override in `about:config` or `about:preferences`. Settings take effect on next browser restart.

## Reference

- [LibreWolf Settings Docs](https://www.librewolf.net/docs/settings/)
- [LibreWolf FAQ](https://www.librewolf.net/docs/faq/)
- [[software/dev-setup|Dev Setup]]
