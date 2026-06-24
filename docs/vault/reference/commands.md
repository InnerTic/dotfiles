# =============================================================================
# QUICK REFERENCE COMMANDS
# Last updated: 2026-06-09
# =============================================================================
#
# NOTE: These aliases are NOT in shell rc files — they need to be re-created
# after a system rebuild. The underlying scripts are at:
#   ~/.local/bin/llama-loader          (llm → interactive model selector)
#   ~/.openclaw/workspace/scripts/     (textgen-start.sh, llama-start.sh)
#   ~/dotfiles/scripts/llama-server.sh (llama-server wrapper with CUDA paths)
# To recreate aliases, add to ~/.zshrc:
#   alias llm='~/.local/bin/llama-loader'
#   alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
#   alias llmk='pkill -f llama-server'
#   alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'
#   alias textgen='~/.openclaw/workspace/scripts/textgen-start.sh'
#   alias textkill='pkill -f "server.py"'
# =============================================================================

# =============================================================================
# LLAMA.CPP MODEL SELECTOR (INTERACTIVE)
# =============================================================================
llm                     # Launch interactive model selector (lists all .gguf in
                        # ~/Downloads/llm_models/, pick by number, starts llama-server)
                        # Alias: llm → llama-loader → ~/.local/bin/llama-loader
                        # Uses llama-server from text-gen venv (not standalone build)
llmstart                # Same as llm (alternative alias)
llm list                # List models without starting server

# =============================================================================
# LLAMA.CPP QUICK CONTROLS
# =============================================================================
llmcheck                # Check which model is running:
                        #   curl http://127.0.0.1:8080/v1/models
llmk                    # Kill [[llama-server]] (alias: llmk → does nothing currently)
                        # Manual: pkill -f llama-server

# API endpoint (once server is running):
#   http://127.0.0.1:8080/v1                  — OpenAI-compatible API base
#   http://127.0.0.1:8080/v1/chat/completions — Chat endpoint
#   http://127.0.0.1:8080/v1/models           — List loaded model

# =============================================================================
# LLAMA.SWAP (ALTERNATIVE — not yet installed)
# =============================================================================
# llama-swap is a Go proxy that lets you hot-swap models without restarting
# the server. Install if you need to switch models frequently.
#   https://github.com/mostlygeek/llama-swap

# =============================================================================
# FORGE (SD WebUI) — Image Generation
# =============================================================================
sdxl                    # Start Forge WebUI on port 7860
                        # Alias → ~/.openclaw/workspace/scripts/forge-start.sh
                        # Path: /workspace/sd-webui-forge-neo
sdxlkill                # Kill Forge: pkill -f "launch.py\|webui.py"
URL: http://172.16.5.1:7860

# =============================================================================
# TEXT GENERATION WEBUI
# =============================================================================
textgen                 # Start TextGen WebUI on port 7861
                        # Alias → ~/.openclaw/workspace/scripts/textgen-start.sh
                        # Path: /workspace/textgen
textkill                # Kill TextGen: pkill -f "server.py"
URL: http://172.16.5.1:7861 (Web) / :5000 (API)

# =============================================================================
# OPENCODE
# =============================================================================
oc                      # OpenCode TUI (alias for 'opencode')
ocl                     # OpenCode with local models (auto-starts [[llama-server]])
                        # Alias → ~/.openclaw/workspace/scripts/opencode-local.sh tui
oclw                    # OpenCode Web with local models
                        # Alias → ~/.openclaw/workspace/scripts/opencode-local.sh web

# Models configured in opencode:
#   llama.cpp/Qwen3-VL-8B-Instruct-abliterated-v2.Q5_K_M.gguf (primary)
#   + 5 other models in ~/Downloads/llm_models/

# =============================================================================
# MODEL SWITCHING IN OPENCODE
# =============================================================================
# In TUI, use: /model <provider>/<model>
#   /model Favorites/big-pickle          — cloud (OpenRouter)
#   /model llama.cpp/<model-filename>    — local (requires llama-server running)

# =============================================================================
# QUICK HELP
# =============================================================================
quickhelp               # Show all AI-related aliases

# =============================================================================
# FASTFETCH
# =============================================================================
# Runs automatically on terminal open (configured in ~/.zshrc)
# Config: ~/.config/fastfetch/config.jsonc
# Note: Powerlevel10k instant prompt disabled to preserve fastfetch colors
# See: github.com/romkatv/powerlevel10k/issues/1834

# =============================================================================
# NETWORK / SYSTEMS
# =============================================================================
# MikroTik Switch: 172.16.88.1
# ZimaBoard (DNS): 172.16.1.1
# Akuma PC: 172.16.5.1
# pihole (LXC): 172.16.12.1

# SSH shortcuts (from ~/.ssh/config):
ssh zima        # ZimaBoard (Unbound + ad-block)
ssh pihole      # pihole LXC (172.16.12.1)
ssh mikrotik    # MikroTik switch

# =============================================================================
# PYTHON VENV (always use, never system Python)
# =============================================================================
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip freeze > requirements.txt   # Save current state

# =============================================================================
# GIT (dotfiles repo)
# =============================================================================
# Repo: git@github.com:InnerTic/dotfiles.git
# Update: cd ~/dotfiles && git pull
# Push changes: cd ~/dotfiles && git add -A && git commit -m "msg" && git push

# =============================================================================
# DOCKER
# =============================================================================
# No Docker. All AI tools run natively with CUDA.

# =============================================================================
# BACKUPS
# =============================================================================
# Mega (rclone): ~/.local/bin/rclone
# Push: ~/.openclaw/workspace/scripts/mega-push.sh
# Pull: ~/.openclaw/workspace/scripts/mega-pull.sh

# =============================================================================
# HISTORICAL — REMOVED / CHANGED
# =============================================================================
# openclaw                  → Not currently installed (venv exists but needs reinstall)
# ~/Documents/select_llama_model.sh → Deleted, replaced by llama-loader (~/.local/bin/)
# alias llma='/home/ken/llama.cpp/build/bin/llama-server' → llama.cpp not built standalone
# llmakill (old alias)      → Not set, use pkill manually
# tmux commands             → tmux not installed
