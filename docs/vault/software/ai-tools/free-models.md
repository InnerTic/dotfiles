# Free Online Models Reference
**Generated: 2026-05-13**
**Source:** OpenCode Zen API + OpenRouter API (live queries)
**How to refresh:** `online-loader` fetches live from both APIs each run

Two providers configured in opencode: `opencode` (Zen) and `openrouter`. Model IDs use format `<provider>/<model-id>` (e.g. `opencode/big-pickle`, `openrouter/qwen/qwen3-coder:free`).

## OpenCode Zen (`opencode/`) — 6 free models

| Model | Context | Best For |
|-------|---------|----------|
| `big-pickle` | 200K | Stealth model. Best [[hat-assistant]]. 128K output, tools, reasoning. |
| `nemotron-3-super-free` | 262K | NVIDIA 120B MoE (12B active). Strongest for [[AGENTS]], code, complex tasks. |
| `ring-2.6-1t-free` | 262K | InclusionAI 1T MoE. [[hat-assistant]], tools. |
| `minimax-m2.5-free` | 197K | MiniMax. Solid mid-weight, tools. |
| `deepseek-v4-flash-free` | ? | Fast, good for quick coding. |
| `trinity-large-preview-free` | 262K | Arcee AI. Reasoning specialist. |

## OpenRouter Free (`openrouter/`) — 29 free models

### Heavy Hitters (Best Quality)
| Model | Context | Best For |
|-------|---------|----------|
| `nvidia/nemotron-3-super-120b-a12b:free` | 262K | Best free OR model for [[AGENTS]]/code |
| `nousresearch/hermes-3-llama-3.1-405b:free` | 131K | Nous 405B, strong general |
| `openai/gpt-oss-120b:free` | 131K | OpenAI open-source 120B, solid all-rounder |
| `openai/gpt-oss-20b:free` | 131K | Lighter OSS model |

### Vision (Image Input)
| Model | Context | Best For |
|-------|---------|----------|
| `google/lyria-3-pro-preview` | 1M | Google multimodal, vision+tools |
| `google/lyria-3-clip-preview` | 1M | Google CLIP-style vision |
| `google/gemma-4-26b-a4b-it:free` | 262K | Mid-size, vision+tools |
| `google/gemma-4-31b-it:free` | 262K | Larger Gemma, vision+tools |
| `nvidia/nemotron-nano-12b-v2-vl:free` | 128K | Lightweight vision-language |

### Code-Focused
| Model | Context | Best For |
|-------|---------|----------|
| `qwen/qwen3-coder:free` | 262K | Strong coding specialist |
| `poolside/laguna-xs.2:free` | 131K | Code-specialized, small |
| `poolside/laguna-m.1:free` | 131K | Code-specialized, larger |

### Reasoning / Thinking
| Model | Context | Best For |
|-------|---------|----------|
| `arcee-ai/trinity-large-thinking:free` | 262K | Chain-of-thought reasoning |
| `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` | 256K | Reason + vision |
| `liquid/lfm-2.5-1.2b-thinking:free` | 33K | Tiny dedicated reasoning model |

### General Purpose
| Model | Context | Best For |
|-------|---------|----------|
| `meta-llama/llama-3.3-70b-instruct:free` | 66K | Solid workhorse, well-known |
| `qwen/qwen3-next-80b-a3b-instruct:free` | 262K | MoE (3B active), fast+big ctx |
| `minimax/minimax-m2.5:free` | 197K | Same model as Zen's minimax-m2.5-free |
| `z-ai/glm-4.5-air:free` | 131K | Zhipu lightweight, tools |
| `openrouter/free` | 200K | Auto-router to best free model |
| `openrouter/owl-alpha` | 1M | Huge context window |
| `inclusionai/ring-2.6-1t:free` | 262K | Same as Zen's ring-2.6-1t-free |

### Utility / Specialty
| Model | Context | Best For |
|-------|---------|----------|
| `baidu/cobuddy:free` | 131K | Chinese-market assistant |
| `baidu/qianfan-ocr-fast:free` | 66K | OCR specialist |
| `cognitivecomputations/dolphin-mistral-24b-venice-edition:free` | 33K | [[hat-unfiltered]], dolphin fine-tune |
| `nvidia/nemotron-3-nano-30b-a3b:free` | 256K | Lightweight MoE, no vision |
| `nvidia/nemotron-nano-9b-v2:free` | 128K | Tiny fast model |
| `meta-llama/llama-3.2-3b-instruct:free` | 131K | 3B, fastest option |
| `liquid/lfm-2.5-1.2b-instruct:free` | 33K | 1.2B, smallest available |

## How to Update This Document

The document is static — models get swapped in/out of free tiers frequently.

**To regenerate:** Run `online-loader` (alias `oll`), which fetches live from both APIs and lets you pick. It also updates opencode config on selection.

**To check current free models manually:**
```bash
# OpenRouter free count
curl -s https://openrouter.ai/api/v1/models | python3 -c "
import json,sys; d=json.load(sys.stdin)
free=[m for m in d['data'] if m['pricing']['prompt']=='0']
print(f'{len(free)} free models')
for m in free: print(f'  {m[\"id\"]} ({m.get(\"context_length\",\"?\")} ctx)')
"
```

**To update this file:** Edit the tables above. The model list, context lengths, and free status should be verified against live API before updating.
