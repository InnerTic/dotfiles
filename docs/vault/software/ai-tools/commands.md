---
tags: [reference, ai-tools, commands]
aliases: [ai-commands, ai-tools, command-reference]
updated: 2026-06-15
---

# AI Tools — Command Reference

Quick reference for all AI-related aliases and commands. See [[software/ai-tools/index]] for setup details.

## llama.cpp (Local Inference)

```bash
llm                    # Interactive model selector
                       # Lists all .gguf in ~/Downloads/llm_models/
                       # Pick by number, starts llama-server

llmcheck               # Check which model is running
                       # curl http://127.0.0.1:8080/v1/models

llmk                   # Kill llama-server
                       # Manual: pkill -f llama-server

llmstart               # Alternative alias for llm
```

**Ports:**
- GPU 0 (RTX 3060): `:8080`
- GPU 1 (Tesla P40): `:8081`

**API Endpoints (once server running):**
```
http://127.0.0.1:8080/v1                    — OpenAI-compatible API base
http://127.0.0.1:8080/v1/chat/completions   — Chat endpoint
http://127.0.0.1:8080/v1/models             — List loaded models
```

---

## Forge (Stable Diffusion WebUI)

```bash
sdxl                   # Start Forge WebUI (port 7860)
                       # Path: /workspace/sd-webui-forge-neo

sdxlkill               # Kill Forge
                       # Manual: pkill -f "launch.py\|webui.py"

URL: http://172.16.5.1:7860
```

---

## TextGen WebUI

```bash
textgen                # Start TextGen WebUI (port 7861)
                       # Path: /workspace/textgen

textkill               # Kill TextGen
                       # Manual: pkill -f "server.py"

Web UI:   http://172.16.5.1:7861
API:      http://172.16.5.1:5000
```

---

## OpenCode (AI Code Assistant)

```bash
oc                     # OpenCode TUI
                       # Alias: opencode

ocl                    # OpenCode TUI with local llama.cpp
                       # Auto-starts llama-server if not running
                       # Uses local models from ~/Downloads/llm_models/

oclw                   # OpenCode Web UI with local models
```

**Model Switching in OpenCode TUI:**
```
/model Favorites/big-pickle           — Cloud provider (OpenRouter)
/model llama.cpp/<model-filename>     — Local (requires llama-server running)
```

**Configured Models:**
- llama.cpp/Qwen3-VL-8B-Instruct-abliterated-v2.Q5_K_M.gguf (primary)
- 5+ other models in `~/Downloads/llm_models/`

---

## Model Files

```bash
# Model directory
~/Downloads/llm_models/

# List available
ls ~/Downloads/llm_models/ | grep .gguf

# Quick symlink
~/Models → ~/Downloads/llm_models/
```

**Available:**
- Qwen2.5-VL-7B (Q4, Q5 variants)
- Qwen3-VL-8B (3 variants: Q4, Q5, abliterated)
- Qwen3-VL-Embedding-2B
- Custom models in `~/Downloads/llm_models/`

---

## Quick Help

```bash
quickhelp              # Show all AI aliases + network info
```

---

## Architecture

**GPU Assignment:**
| GPU | Model | Port | CUDA_VISIBLE_DEVICES |
|-----|-------|------|----------------------|
| RTX 3060 (12GB) | Small/medium LLMs, SD | 8080 | 0 |
| Tesla P40 (24GB) | Large LLMs (30B-70B Q4) | 8081 | 1 |

**Startup (manual):**
```bash
# GPU 0 — RTX 3060
export CUDA_VISIBLE_DEVICES=0
~/workspace/llama.cpp/build/bin/llama-server -m ~/models/small.gguf -ngl 35 --port 8080

# GPU 1 — Tesla P40
export CUDA_VISIBLE_DEVICES=1
~/workspace/llama.cpp/build/bin/llama-server -m ~/models/large.gguf -ngl 64 --port 8081
```

---

## Related

- [[software/ai-tools/llama-setup]] — Full llama.cpp build & setup
- [[software/ai-tools/index]] — Overview of all AI tools
- [[software/ai-tools/model-management]] — Where models live, how to add/switch
- [[reference/troubleshooting]] — Common issues
