# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# ── AI Aliases ──────────────────────────────────────────────
alias llm='~/.local/bin/llama-loader'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'
alias textgen='~/.openclaw/workspace/scripts/textgen-start.sh'
alias textkill='pkill -f "server.py"'
alias quickhelp='cat ~/dotfiles/docs/quick-commands.txt'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
