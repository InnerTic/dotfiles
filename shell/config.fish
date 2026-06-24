# ── AI Aliases ──────────────────────────────────────────────
alias llm='~/.local/bin/llama-loader'
alias test-llm='~/.local/bin/test-llma-loader'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
alias llmstart='~/infra/llama-server.sh'
alias llsd='~/infra/forge-llm.sh'
alias textgen='~/infra/textgen-start.sh'
alias textkill='pkill -f "server.py"'
alias sdxl='~/infra/forge-start.sh'
alias quickhelp='cat ~/dotfiles/docs/quick-commands.txt'
alias oc='opencode'
alias ocl='opencode --provider llama.cpp'
alias oclw='opencode web --provider llama.cpp'

# ── Greeting ────────────────────────────────────────────────
function fish_greeting
    fastfetch
end

# uv
fish_add_path "/home/ken/.local/bin"
