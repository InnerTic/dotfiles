# Free LLM API Providers — Backup Options
**Generated: 2026-05-13**
**Sources:** awesome-free-llm-apis (GitHub), free-llm.com, tokenmix.ai, awesomeagents.ai

OpenCode Zen and OpenRouter free models get swapped in/out. These are providers with genuinely free tiers (no credit card, no expiry) that you can register for and add as additional providers in opencode for redundancy.

## Tier 1: Best Free Tiers (No Credit Card, No Expiry)

| Provider | Sign Up | Best Free Model | Daily Limit | Speed | OpenAI Compat | Notes |
|----------|---------|----------------|-------------|-------|---------------|-------|
| **Google AI Studio** | aistudio.google.com | Gemini 2.5 Flash | 1,500 req/day | Fast | Yes | 1M ctx, vision, best overall |
| **Groq** | console.groq.com | Llama 3.3 70B | ~1,000 req/day | **700+ TPS** | Yes | Fastest inference available |
| **Cerebras** | cloud.cerebras.ai | Llama 3.3 70B | ~1,700 req/day | ~1,000 TPS | Yes | Highest daily capacity |
| **SambaNova** | sambanova.ai | Llama 3.3 70B | Free tier | 294 TPS | Yes | Groq alternative |
| **Mistral** | console.mistral.ai | Mistral Small | ~86K req/day | Moderate | Yes | European, privacy-focused |

## Tier 2: Good for Prototyping

| Provider | Sign Up | Best Free Model | Limits | OpenAI Compat | Notes |
|----------|---------|----------------|--------|---------------|-------|
| **HuggingFace Inference** | huggingface.co | 1000s of models | Variable, shared | No (own API) | Best for experimentation |
| **GitHub Models** | github.com/marketplace/models | GPT-4o, Llama 3.1 | ~150 req/day | Yes | GitHub account needed |
| **Cloudflare Workers AI** | dash.cloudflare.com | Llama 3.3 70B | ~300 req/day, 30 TPS | Yes | Edge deployment |
| **NVIDIA NIM** | build.nvidia.com | Llama 3.3 70B | Prototyping | Yes | NVIDIA ecosystem |
| **Fireworks AI** | fireworks.ai | Various | Free tier | Yes | Fast inference |

## Tier 3: Limited but Useful

| Provider | Sign Up | Best Free Model | Limits | Notes |
|----------|---------|----------------|--------|-------|
| **Together AI** | together.ai | Various | $1 credit (no CC) | One-time eval credit |
| **Cohere** | dashboard.cohere.com | Command R+ | ~33 req/day | Embeddings + RAG specialist |
| **AI21 Labs** | ai21.com | Jamba 1.5 | $10 credit | Jamba architecture |
| **Scaleway** | scaleway.com | Free tier | Limited | EU-based |
| **OVH AI Endpoints** | ovhcloud.com | Free tier | Limited | EU-based |

## How to Add a Provider to OpenCode

Each provider needs two entries:

**1. `~/.local/share/opencode/auth.json`** — store the API key:
```json
{
  "groq": {
    "type": "api",
    "key": "gsk_your_groq_key_here"
  },
  "google-ai-studio": {
    "type": "api",
    "key": "AIza_your_google_key_here"
  }
}
```

**2. `~/.config/opencode/opencode.json`** — configure models:
```json
{
  "providers": {
    "groq": {
      "baseUrl": "https://api.groq.com/openai/v1",
      "models": {
        "llama-3.3-70b-versatile": {}
      }
    },
    "google-ai-studio": {
      "baseUrl": "https://generativelanguage.googleapis.com/v1beta/openai",
      "models": {
        "gemini-2.0-flash": {}
      }
    }
  }
}
```

Then use `/model groq/llama-3.3-70b-versatile` in opencode TUI or set as `"model": "groq/llama-3.3-70b-versatile"` in config.

## Recommended Stacking Strategy

For maximum uptime when one provider cuts you off:

1. **Default:** `opencode/big-pickle` (Zen, easiest)
2. **Fallback 1:** `openrouter/nvidia/nemotron-3-super-120b-a12b:free` (most capable free)
3. **Fallback 2:** Register **Groq** (fastest, different infrastructure)
4. **Fallback 3:** Register **Google AI Studio** (most generous daily limit)
5. **Local:** `llama.cpp/<model>` (always works, no internet)

## Model Selection Strategy: Code vs Tool Calling

Don't waste a capable general model on pure code generation, and don't expect a code-specialist to handle tool calls well.

| Task | Reach For | Why |
|------|-----------|-----|
| **Writing code, debugging** | `qwen/qwen3-coder`, `poolside/laguna-*` | Trained on code, better at syntax, less verbose |
| **Tool calling, [[AGENTS]], planning** | `nvidia/nemotron-3-super`, `google/gemini-flash`, `big-pickle` | General reasoning, follows instructions reliably |
| **Quick drafts, simple edits** | `meta-llama/llama-3.2-3b`, `liquid/lfm-1.2b` | Tiny, fast, cheap on quota |
| **Vision, image understanding** | `google/lyria-3-*`, `google/gemma-4-*` | Multimodal native |
| **Heavy reasoning, complex tasks** | `opencode/big-pickle`, `arcee-ai/trinity-large` | Deep chain-of-thought |

**Golden rule:** GitHub Copilot-tier models (finetuned Claude-style) burn through free quota fast if you let them do tool loops. Save those for pure chat/docs. Let the open-weight MoE models (Nemotron, Qwen Next) handle the tool-calling heavy lifting — they're free and built for it.

## How to Refresh This Document

The free tier landscape [[changelog]] monthly. To re-check:
```bash
# Check opencode docs for current Zen free models
curl -s https://opencode.ai/docs/zen | grep -i 'free model'

# Check OpenRouter current free count
curl -s https://openrouter.ai/api/v1/models | python3 -c "
import json,sys; d=json.load(sys.stdin)
free=[m for m in d['data'] if m['pricing']['prompt']=='0']
print(f'{len(free)} free models on OpenRouter')
"
```
