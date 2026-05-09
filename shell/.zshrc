# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (built-in + custom)
plugins=(git)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Custom plugins must be sourced AFTER OMZ
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.venvs/openclaw/bin:$PATH"

# OpenClaw Completion
source "/home/ken/.openclaw/completions/openclaw.zsh"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# =============================================================================
# LLAMA.CPP QUICK ALIASES
# =============================================================================
alias llmakill='pkill -f llama-server'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'

# Load Qwen3.5 4B
alias llmqwen='llmakill 2>/dev/null; sleep 1; /home/ken/llama.cpp/build/bin/llama-server -m /home/ken/Downloads/llm_models/Qwen3.5-4B-Uncensored-HauhauCS-Aggressive-Q8_0.gguf -c 16384 -ngl 35 --port 8080 &'

# Load Phi-4 Mini
alias llmphi='llmakill 2>/dev/null; sleep 1; /home/ken/llama.cpp/build/bin/llama-server -m /home/ken/Downloads/llm_models/phi_4_mini_uncensored.Q5_K_M.gguf -c 16384 -ngl 35 --port 8080 &'

# Load GPT-5 Heretic
alias llmheretic='llmakill 2>/dev/null; sleep 1; /home/ken/llama.cpp/build/bin/llama-server -m /home/ken/Downloads/llm_models/GPT-5-Distill-Qwen3-4B-Instruct-Heretic.Q6_K.gguf -c 8192 -ngl 35 --port 8080 &'

# Load Qwen3.5 9B (needs more VRAM)
alias llmqwen9='llmakill 2>/dev/null; sleep 1; /home/ken/llama.cpp/build/bin/llama-server -m /home/ken/Downloads/llm_models/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf -c 8192 -ngl 20 --port 8080 &'

# Load Qwen2.5 7B
alias llmaqwen='llmakill 2>/dev/null; sleep 1; /home/ken/llama.cpp/build/bin/llama-server -m /home/ken/Downloads/llm_models/Qwen2.5-7B-Instruct-Uncensored.Q6_K.gguf -c 16384 -ngl 35 --port 8080 &'

# =============================================================================
# TEXT GEN WEBUI & SDXL QUICK ALIASES
# =============================================================================

# Text Generation WebUI

# SDXL/Forge WebUI
alias sdxl='cd ~/forge-webui && ./webui.sh &'
alias sdxlkill='pkill -f "webui.sh\|ldm\|torch"'

# Aliases summary
alias quickhelp='echo "llmqwen|llmphi|llmheretic|llmcheck - llama-server"
echo "textgen|textkill - text gen webui"
echo "sdxl|sdxlkill - forge/sdxl webui"'


# TextGen WebUI
alias textgen='~/.openclaw/workspace/scripts/textgen-tmux.sh'
alias textkill='tmux kill-session -t textgen 2>/dev/null; pkill -f "server.py"'

# KoboldCpp
alias koboldcpp='~/.openclaw/workspace/scripts/koboldcpp-tmux.sh'
alias koboldkill='tmux kill-session -t koboldcpp 2>/dev/null; pkill -f koboldcpp'
alias kobold-select='bash ~/.openclaw/workspace/scripts/koboldcpp-select.sh'
export PATH="$HOME/.local/bin:$PATH"
fastfetch
export PATH="$PATH:$(pwd)/node_modules/.bin"

# ── SERVICE START/STOP ALIASES ──
alias sdxl='~/.openclaw/workspace/scripts/forge-start.sh'
alias sdxlkill='pkill -f "launch.py\|webui.py"'
alias textgen='~/.openclaw/workspace/scripts/textgen-start.sh'
alias textkill='pkill -f "server.py"'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'

# OpenCode with local models
alias opencode-local='~/.openclaw/workspace/scripts/opencode-local.sh tui'
alias opencode-local-web='~/.openclaw/workspace/scripts/opencode-local.sh web'

# opencode
export PATH=/home/ken/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# llama-loader aliases
alias llama-loader="/home/ken/.local/bin/llama-loader"
alias kill-llama="/home/ken/.local/bin/kill-llama.fish"

export PATH="$HOME/bin:$PATH"

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"
export OLLAMA_API_BASE=http://127.0.0.1:8080
