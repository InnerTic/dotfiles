# Research Wiki Structure

Proposed organization for an AI model research wiki. This is a living document — structure should evolve as the field does.

## Design Goals

- **Accuracy**: Prefer factual information over speculation. Mark unknowns as unknown.
- **Connectivity**: Notes should link to related concepts. A model should lead to its architecture, training methods, formats, variants, and related technologies.
- **Scalability**: Structure should accommodate future developments without major reorganization.
- **Practicality**: Emphasize real-world applications. Help answer: Can I run this? What is it good at? How is it different? What should I use instead?
- **Incremental growth**: Completion is not required before usefulness.

## Research Philosophy

Treat AI development as an evolving ecosystem rather than a collection of isolated products. Relationships between technologies are often as important as the technologies themselves.

## Sections

### Inbox
Capture new terms, questions, and ideas for later investigation. Nothing interesting should be lost simply because it cannot be researched immediately.

### Concepts
Fundamental ideas: Dense models, MoE, Distillation, RLHF, DPO, Quantization, Context windows.

### Model Families
Major lineages: Qwen, Mistral, DeepSeek, Llama, Gemma, Phi.

### Individual Models
Specific models with specs, capabilities, variants, requirements, performance.

### Variants and Fine Tunes
Community modifications: Hermes, Dolphin, Heretic, Abliterated, merges.

### Architectures
Structural approaches: Dense, MoE, Hybrid, emerging.

### Training Methods
How models are created: Pretraining, SFT, RLHF, DPO, Distillation.

### Formats
Storage/deployment: GGUF, GPTQ, AWQ, EXL2, MLX.

### Runtimes
Deployment software: llama.cpp, Ollama, OpenClaw, vLLM, KoboldCpp.

### Benchmarks
Evaluation methods: MMLU, HumanEval, Arena, coding benchmarks.

### Hardware
Requirements and performance: CPU, GPU, RAM, VRAM, quantization effects.

### Naming Conventions
Decode model names: parameter counts, variant names, quant labels, architecture identifiers.

### Glossary
Concise definitions for technical terminology.

### Research
Open questions and active investigations: comparisons, experiments, emerging technologies, community trends.

### Experiments
Personal testing and observations: prompt tests, quant comparisons, runtime evaluations, agent workflows.

### Cross Linking
Every note should ask: What does this connect to? Parent technologies, derived technologies, related concepts, compatible software, similar models.

## Long Term Goal

Build a comprehensive, maintainable, and practical knowledge base of AI models and related technologies that remains useful to both newcomers and experienced practitioners.
