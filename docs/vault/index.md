---
title: Vault Index
---

# Vault Index

Personal knowledge base — system configs, AI tools, reference docs, and project notes.

## Getting Started

| If you want to... | Go here |
|---|---|
| Recover from a fresh OS install | [[QUICK-START]] |
| Rebuild the whole system | [[system/system-memory]] |
| Find something specific | [[map]] |
| See recent [[changelog]] | [[changelog]] |

## Sections

| Section | Contents |
|---|---|
| [[system/backup-checklist\|System]] | [[drives-and-mounts]], [[drives-and-mounts]], backups, rebuild notes, boot [[QUICK-START]] |
| [[hardware/gpu/config-notes\|Hardware]] | GPU config, CUDA, VFIO passthrough |
| [[software/dev-setup\|Software]] | AI tools, KDE, prompt-hats, Quartz, SearXNG, packages, gaming |
| [[reference/architecture-snapshot\|Reference]] | Architecture, commands, [[faq]], [[glossary]], SSH, keyd, LXC, PCI |
| [[context/INDEX\|Context]] | AI rebuild context — authoritative system state docs |
| [[projects/README\|Projects]] | Active project docs — translation pipeline, SD Forge |
| [[scripts/README\|Scripts]] | Install/reinstall scripts indexed in rebuild order |
| [[research/runbook-architecture\|Research]] | Runbook architecture, vault organization principles |

## Quick Links

- [[software/ai-tools/commands|AI Command Reference]] — llm, sdxl, textgen, oc
- [[software/ai-tools/llama-setup|llama.cpp Setup]] — build, GPU layout, dual GPU
- [[reference/commands|Full Command Reference]]
- [[reference/quick-commands|Quick Cheat Sheet]]
- [[reference/glossary|Glossary]]
- [[reference/bugs-and-workarounds|Known Bugs & Workarounds]]
- [[software/opencode/plugins|OpenCode Plugins]]

## Other

- [[archive/scratchpad|Archive]] — historical docs, old plans, [[scratchpad]]
- [[software/prompt-hats/INDEX|Prompt Hats]] — 22 stable + 8 experimental prompt patterns

## Wiki Health

<div id="index-[[health]]">
  <p>Checking...</p>
</div>

<script>
(async function() {
  const el = document.getElementById('index-[[health]]');
  try {
    const res = await fetch('/status');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const d = await res.json();
    const built = new Date(d.build_time);
    const age = Math.floor((Date.now() - built.getTime()) / 1000);
    const ago = age < 60 ? age + 's' : age < 3600 ? Math.floor(age/60) + 'm' : Math.floor(age/3600) + 'h';
    el.innerHTML = '<table><tr><td>Status</td><td>' + (d.file_count > 0 ? 'OK' : 'DEGRADED') + '</td></tr><tr><td>Files</td><td>' + d.file_count + '</td></tr><tr><td>Built</td><td>' + ago + ' ago</td></tr></table>';
  } catch(e) {
    el.innerHTML = '<p>Unreachable: ' + e.message + '</p>';
  }
})();
</script>
