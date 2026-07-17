# Local VLM Research

Vision-language models suitable for an "image judge / prompt refiner / controller eye" layer in an SDXL pipeline on dual-GPU (RTX 3060 + Tesla P40).

## 1. Qwen2-VL family (primary recommendation)

These are the strongest local-feasible VLMs for reasoning + vision grounding.

Models: Qwen2-VL-2B-Instruct, Qwen2-VL-7B-Instruct, Qwen2-VL-72B-Instruct (not local).

Strong image understanding + reasoning chain. Can do prompt adherence checks, composition critique, object + text reading. Works well as a feedback controller.

Best fit: "vision → structured critique → prompt correction"

## 2. LLaVA family (lightweight fallback)

The classic local VLM glue models. LLaVA-1.5-7B, LLaVA-1.6-Mistral-7B, LLaVA-Next-13B.

Easy to run locally (7B feasible on this stack), good general image description, decent reasoning, script-friendly. Weaker structured reasoning than Qwen2-VL, weaker judge scoring.

Best role: fast "sanity check eye" for SDXL outputs.

## 3. InternVL (deep judge)

Research-grade vision cognition. InternVL2-8B, InternVL2-26B.

Very strong visual reasoning, better at spatial structure, multi-object consistency, detailed critique. Heavier inference, more complex to run.

Best role: batch/offline deep judge (26B on P40).

## 4. BLIP / BLIP-2 (utility layer)

Fast captioning, cheap image summarization, good preprocessing for tagging/dataset building/prompt seeding.

Not good for critique loops.

## Recommended stack

| Role | Model |
|------|-------|
| Controller brain (text) | Mixtral / 7B MoE |
| Vision judge (primary) | Qwen2-VL-7B-Instruct |
| Vision judge (fallback) | LLaVA-1.6-Mistral-7B |
| Generator | SDXL (3060) |
| Deep judge (offline) | InternVL2-26B (P40) |

## Key insight

For a vision model controlling SDXL loops, the key property is structured output — not size. Test prompts like "Rate this image 0–10 for prompt adherence. List 3 concrete visual issues. Propose a revised SDXL prompt." Some models behave as judges; others just describe.

## Candidate models on disk

- noctrex/Qwen3-VL-30B-A3B-Instruct-1M-MXFP4_MOE-GGUF (31B)
- noctrex/Qwen3-VL-30B-A3B-Thinking-1M-MXFP4_MOE-GGUF (31B)
- noctrex/Jan-v2-VL-max-MXFP4_MOE-GGUF (31B)
- noctrex/Kimi-VL-A3B-Thinking-2506-MXFP4_MOE-GGUF (16B)
- vltnmmdv/deepseek-moe-16b-base (16B)
- micdun/* (various 7B Qwen2.5 VL MoE fine-tunes)
