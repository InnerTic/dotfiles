╔══════════════════════════════════════════════════════════════════════════════╗
║                         QUICK START COMMANDS                                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ── LLAMA.CPP (local AI models on port 8080) ──                            ║
║                                                                              ║
                       ║
║    llmcheck      Check which model is running                                 ║
║    llmakill      Kill llama-server                                            ║
║                                                                              ║
║  ── FORGE (SD WebUI) - Image Generation ──                                   ║
║                                                                              ║
║    sdxl          Start Forge WebUI (port 7860)                               ║
║    sdxlkill      Kill Forge                                                  ║
║    URL: http://172.16.5.1:7860                                               ║
║                                                                              ║
║  ── TEXT GEN WEBUI ──                                                        ║
║                                                                              ║
║    textgen       Start TextGen WebUI (port 7861)                            ║
║    textkill      Kill TextGen                                                ║
║    URL: http://172.16.5.1:7861 (Web) / :5000 (API)                         ║
║                                                                              ║
║  ── OPENCLAW ──                                                             ║
║                                                                              ║
║    openclaw tui              Start TUI                                       ║
║    openclaw dashboard       Open browser dashboard                          ║
║    openclaw status          Check status                                    ║
║    openclaw gateway restart Restart gateway                                  ║
║                                                                              ║
║  ── OPENCODE (Local Models) ──                                              ║
║                                                                              ║
║    opencode-local           OpenCode TUI with local models                  ║
║    opencode-local-web       OpenCode Web UI with local models              ║
║    Models: local/qwen2.5-7b, local/qwen3.5-4b, local/phi-4-mini            ║
║    (Requires llama-server running on port 8080)                              ║
║                                                                              ║
║  ── MODEL SWITCHING IN OPENCLAW ──                                           ║
║                                                                              ║
║    ☁️ CLOUD (Favorites):                                                   ║
║    /model Favorites/big-pickle    Primary                                   ║
║    /model Favorites/gpt-5-nano    Backup                                    ║
║                                                                              ║
║    ☁️ OPENROUTER FREE FALLBACKS:                                            ║
║    /model OpenRouter/openrouter/auto              Auto-select best free     ║
║              ║
║    /model OpenRouter/nvidia/nemotron-nano-9b-v2:free  Nemotron 9B         ║
║    /model OpenRouter/openai/gpt-oss-20b:free     GPT-OSS 20B              ║
║                                                                              ║
║    🖥️ LOCAL (requires llama-server running):                                ║
║                                                                              ║
║  ── MODEL FILES ──                                                          ║
║                                                                              ║
║    Local models: ~/Downloads/llm_models/                                     ║
║    Active model: ~/.openclaw/workspace/models/                               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

NOTES:
- Local models: restart llama-server first with llmqwen/llmphi/llmheretic
- Cloud models: work instantly in OpenClaw, no server restart needed
- OpenRouter free models: automatic fallback when Big Pickle is rate limited
- All aliases added to ~/.zshrc - source ~/.zshrc to activate

Quick reference: type 'quickhelp' in terminal
