╔══════════════════════════════════════════════════════════════════════════════╗
║                         QUICK START COMMANDS                                 ║
║                     Last updated: 2026-05-13                                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ── LLAMA.CPP (local AI models on port 8080) ──                            ║
║                                                                              ║
║    llm           Interactive model selector (lists & picks by number)        ║
║    llmcheck      Check which model is running                                ║
║    llmk          Kill llama-server (manual: pkill -f llama-server)           ║
║                                                                              ║
║  ── FORGE (SD WebUI) - Image Generation ──                                   ║
║                                                                              ║
║    sdxl          Start Forge WebUI (port 7860)                               ║
║    sdxlkill      Kill Forge                                                  ║
║    URL: http://172.16.5.1:7860                                               ║
║                                                                              ║
║  ── TEXT GENERATION WEBUI ──                                                 ║
║                                                                              ║
║    textgen       Start TextGen WebUI (port 7861)                            ║
║    textkill      Kill TextGen                                                ║
║    URL: http://172.16.5.1:7861 (Web) / :5000 (API)                         ║
║                                                                              ║
║  ── OPENCODE ──                                                             ║
║                                                                              ║
║    oc            OpenCode TUI                                                ║
║    ocl           OpenCode with local llama.cpp model                         ║
║    oclw          OpenCode Web UI with local model                           ║
║                                                                              ║
║  ── QUICK HELP ──                                                            ║
║                                                                              ║
║    quickhelp     Lists all AI aliases                                        ║
║                                                                              ║
║  ── MODEL FILES ──                                                          ║
║                                                                              ║
║    Local models: ~/Downloads/llm_models/                                     ║
║    Available: Qwen2.5-VL-7B (Q4/Q5), Qwen3-VL-8B (3 variants),              ║
║               Qwen3-VL-Embedding-2B                                          ║
║                                                                              ║
║  ── NETWORK ──                                                               ║
║                                                                              ║
║    Akuma: 172.16.5.1    DNS/Zima: 172.16.1.1                                ║
║    pihole: 172.16.12.1  MikroTik: 172.16.88.1                               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

NOTES:
- Models: run `llm` to select interactively from /home/ken/Downloads/llm_models/
- llama-server binary comes from text-gen venv (not standalone build)
- All aliases in ~/.zshrc — source ~/.zshrc to activate
- Dotfiles repo: git@github.com:InnerTic/dotfiles.git
