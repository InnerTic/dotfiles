# CachyOS config (may not exist on Debian)
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
  source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# --- AI aliases ---
alias llm='llama-loader'
alias test-llm='test-llma-loader'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
