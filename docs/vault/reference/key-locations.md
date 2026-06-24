=== KEY LOCATIONS ===
# Last updated: 2026-05-13

# === AI MODELS ===
MODELS:
  ~/Downloads/llm_models/
  # 6 GGUF files, mostly Qwen3/Qwen2.5-VL 8B variants
  # Managed by: llama-loader (~/.local/bin/)

# === LLAMA.CPP / LLAMA-SERVER ===
LLAMA_SERVER_BIN:
  ~/.openclaw/workspace/text-generation-webui/installer_files/env/lib/python3.13/site-packages/llama_cpp_binaries/bin/[[llama-server]]
  # NOTE: Not a standalone build. Comes from text-gen venv's llama_cpp_python package.
  # No separate ~/llama.cpp/ build exists currently.

MODEL_SELECTOR:
  ~/.local/bin/llama-loader
  # Interactive script that lists models and starts llama-server
  # Also updates ~/.config/opencode/opencode.json with the selected model

# === FORGE (SD WebUI) ===
FORGE:
  Path: /workspace/[[sd-webui-forge-neo]]
  Script: ~/.openclaw/workspace/scripts/[[forge-start]].sh
  Port: 7860

# === TEXT GEN WEBUI ===
TEXTGEN:
  Path: /workspace/textgen
  # Also duplicated at: ~/.openclaw/workspace/text-generation-webui/
  Script: ~/.openclaw/workspace/scripts/textgen-start.sh
  Port: 7861
  API: :5000

# === OPENCODE ===
OPENCODE:
  Config: ~/.config/opencode/opencode.json
  Auth: ~/.local/share/opencode/auth.json
  Binary: ~/.opencode/bin/opencode
  [[plugins]]: 12 (listed in opencode.json)
  Provider: llama.cpp (local), OpenRouter (cloud)

# === OPENCLAW ===
OPENCLAW:
  Config: ~/.openclaw/openclaw.json
  Workspace: ~/.openclaw/workspace/
  Venv: ~/.venvs/openclaw/
  Status: NOT currently in PATH (venv exists but binary not found)
  # Needs reinstall if needed

# === SEARXNG ===
SEARXNG:
  Path: /mnt/workspace/searxng/
  URL: http://127.0.0.1:8888
  Service: user systemd (enabled, auto-start)

# === DOTFILES ===
DOTFILES:
  Repo: ~/dotfiles/
  Docs: ~/dotfiles/docs/context/
  SSH: git@github.com:InnerTic/dotfiles.git (configured)
  Git user: InnerTic / innertic@users.noreply.github.com

# === WORKSPACE ===
WORKSPACE:
  Primary: /mnt/workspace/
  Symlink: /workspace → /mnt/workspace (for Steam Proton Z: drive compat)

# === STORAGE DRIVES ===
SSD_STORAGE:
  Mount: /mnt/ssd_storage (sdb1, ext4)
  Bind [[drives-and-mounts]]: Documents, Downloads, Pictures, Videos, Desktop, Music, go, MEGA
DATA_HDD:
  Mount: /mnt/data (sdc2, ntfs-3g)
VM_DISKS:
  Mount: /var/lib/libvirt/images (sde1, xfs) — VM storage
WORKSPACE_DRIVE:
  Mount: /mnt/workspace (nvme0n1p1, ext4)

# === DOCS / BACKUP ===
DOCS:
  /mnt/workspace/docs/system_profile_summary.txt        # Current system profile
  /mnt/workspace/docs/Documents/system_backup/           # This directory (backup refs)

# === HISTORICAL (old paths, no longer valid) ===
# ~/llama.cpp/build/bin/llama-server  → Never built standalone
# ~/forge-webui/                      → Moved to /workspace/sd-webui-forge-neo
# ~/Documents/select_llama_model.sh   → Deleted, replaced by llama-loader
# /home/ken/llama.cpp/                → Never cloned
