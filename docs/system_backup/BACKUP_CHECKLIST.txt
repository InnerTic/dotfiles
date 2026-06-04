╔══════════════════════════════════════════════════════════════════════════════╗
║                         BACKUP CHECKLIST                                     ║
║                    What to Save Before System Change                          ║
║                    CURRENT as of 2026-05-13                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

═══ CRITICAL - MUST BACKUP ======

□ HOME DIR FILES:
  ☐ ~/Downloads/llm_models/                    - All GGUF model files (6 models)
  ☐ ~/Documents/
      ☐ system_backup/                          - This whole directory
      ☐ QUICK_COMMANDS.txt                     - Quick ref (condensed)
      ☐ commands.txt                           - Full command ref

□ CONFIG FILES:
  ☐ ~/dotfiles/                                - Full dotfiles repo (includes aliases, zshrc)
  ☐ ~/.config/opencode/opencode.json           - OpenCode config (12 plugins)
  ☐ ~/.local/share/opencode/auth.json          - Auth keys for providers
  ☐ ~/.config/systemd/user/searxng.service     - SearXNG user systemd unit
  ☐ ~/.local/bin/llama-loader                  - Interactive GGUF model selector
  ☐ /etc/fstab                                 - All drive mounts + bind mounts

□ VENVS TO REBUILD:
  ☐ ~/.openclaw/workspace/text-generation-webui/installer_files/env/  - TextGen venv
    (includes llama-server binary, oobabooga dependencies)
  ☐ ~/.venvs/openclaw/                         - OpenClaw venv (if used)

═══ WHAT TO REBUILD ======

□ AI Services (via scripts, not standalone builds):
  ☐ llama-server (from text-gen venv's llama_cpp_binaries pip package)
    → Use: ~/.local/bin/llama-loader
  ☐ Text Gen WebUI  → textgen-start.sh (port 7861)
  ☐ SDXL/Forge       → forge-start.sh (port 7860)

□ Services to start:
  ☐ llama-loader (interactive model selector)
  ☐ SearXNG (user systemd unit → searxng.service)
  ☐ TextGen WebUI (textgen-start.sh)
  ☐ Forge WebUI (forge-start.sh)

==== QUICK VERIFY COMMANDS ====

llmcheck                  # Verify local model (curl localhost:8080/v1/models | jq)
curl http://127.0.0.1:8888  # SearXNG
curl http://127.0.0.1:7860  # Forge
curl http://127.0.0.1:7861  # TextGen

==== AFTER REBOOT, RUN: ====

source ~/.zshrc
llm                         # Interactive model selector
# Or manually: ~/.local/bin/llama-loader
