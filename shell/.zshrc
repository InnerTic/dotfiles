# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Custom plugins
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/home/ken/.opencode/bin:$PATH"
export PATH="$HOME/.venvs/openclaw/bin:$PATH"

# ── OpenClaw ──────────────────────────────────────────────────────────────────
source "/home/ken/.openclaw/completions/openclaw.zsh"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ── LLM MODEL LOADER (dynamic) ──────────────────────────────────────────────
alias llm='llama-loader'
alias llmk='kill-llama'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'

# ── SDXL / Forge ─────────────────────────────────────────────────────────────
alias sdxl='~/.openclaw/workspace/scripts/forge-start.sh'
alias sdxlkill='pkill -f "launch.py\|webui.py"'

# ── Text Generation WebUI ────────────────────────────────────────────────────
alias textgen='~/.openclaw/workspace/scripts/textgen-start.sh'
alias textkill='pkill -f "server.py"'

# ── OpenCode ─────────────────────────────────────────────────────────────────
alias oc='opencode'
alias ocl='~/.openclaw/workspace/scripts/opencode-local.sh tui'
alias oclw='~/.openclaw/workspace/scripts/opencode-local.sh web'

# ── Commands Search ─────────────────────────────────────────────────────────
alias quickhelp='alias | grep -E "^(llm|sdxl|textgen|oc|llmk)" | sort'

# Search commands/docs — fuzzy search through dotfiles docs
# Usage: q <term>         (search all doc files)
#        q                (fzf interactive)
q() {
  local docs="$HOME/dotfiles/docs"
  if [ -d "$docs" ]; then
    if [ $# -eq 0 ]; then
      cat "$docs"/*.txt 2>/dev/null | fzf
    else
      grep -ri -- "$*" "$docs" 2>/dev/null | grep -v "^Binary" || echo "No matches in docs"
    fi
  else
    echo "dotfiles docs not found at $docs"
  fi
}

# ── Completion ───────────────────────────────────────────────────────────────
zstyle ':completion:*' menu select
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"
