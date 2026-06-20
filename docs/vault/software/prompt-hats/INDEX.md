---
tags: [navigation, index, hats]
aliases: [hat-system, prompt-hats, role-hats]
updated: 2026-06-20
---

# Prompt Hat System

Role-switching prompt stack for local models (llama.cpp webchat, OpenCode, etc.).  
Each hat is a self-contained operating mode with boundaries, input expectations, and output style.

## Usage

1. Open the hat file for the role you want
2. Copy the full prompt block
3. Paste into llama.cpp webchat system prompt or as a session prefix

Combine hats by concatenating: start with [[core-baseline]], append the role hat(s).

## 🎯 Core

| # | Hat | When to use |
|---|-----|-------------|
| 0 | [[core-baseline]] | Shared prefix — consistency baseline for all roles |
| 1 | [[hat-researcher]] | Deep investigation, evidence-structured analysis |
| 2 | [[hat-coder]] | Write, debug, or review code |
| 3 | [[hat-translator]] | Translate while preserving meaning, tone, intent |
| 4 | [[hat-problem-solver]] | Break down complex problems into solvable components |
| 5 | [[hat-summarizer]] | Compress information, preserve meaning |
| 6 | [[hat-assistant]] | Default — clear, direct, practical responses |

## 🧩 System Layer Roles

| # | Hat | When to use |
|---|-----|-------------|
| 7 | [[hat-orchestrator]] | Break task into sub-tasks, assign roles internally |
| 8 | [[hat-analyst]] | Understand how something works, fails, or behaves |
| 9 | [[hat-experimenter]] | Generate hypotheses and test strategies |

## ⚙️ Engineering Expansion

| # | Hat | When to use |
|---|-----|-------------|
| 10 | [[hat-architect]] | Design systems before implementation |
| 11 | [[hat-debugger]] | Isolate and explain problems in systems or code |
| 12 | [[hat-refactor]] | Improve code/systems without changing behavior |

## 🌐 Language + Communication

| # | Hat | When to use |
|---|-----|-------------|
| 13 | [[hat-translator-plus]] | Translate with full intent, tone, subtext preservation |
| 14 | [[hat-writer]] | Produce clear, organized written content |
| 15 | [[hat-clarifier]] | Resolve unclear or underspecified requests |

## 🧠 Thinking Modes

| # | Hat | When to use |
|---|-----|-------------|
| 16 | [[hat-strategist]] | Evaluate options and recommend a path |
| 17 | [[hat-minimalist]] | Reduce complexity aggressively without losing meaning |
| 18 | [[hat-forensic]] | Examine for hidden structure or intent |

## 🧰 Practical Use Set

| # | Hat | When to use |
|---|-----|-------------|
| 19 | [[hat-homelab]] | Design, debug, optimize local infrastructure |
| 20 | [[hat-automation]] | Convert repetitive tasks into scripts or workflows |
| 21 | [[hat-learning]] | Teach concepts step-by-step |

## File Index

```
prompt-hats/
├── INDEX.md                  ← This file
├── core-baseline.md          ← Shared prefix
├── hat-researcher.md         ← 🔎 Deep Explorer
├── hat-coder.md              ← 🧑‍💻 Execution Engineer
├── hat-translator.md         ← 🌐 Meaning Preservation
├── hat-problem-solver.md     ← 🧠 Systems Thinking
├── hat-summarizer.md         ← 🧾 Compression Engine
├── hat-assistant.md          ← 🎭 General Purpose
├── hat-orchestrator.md       ← 🧩 Meta Controller
├── hat-analyst.md            ← 🧠 Diagnostic Thinker
├── hat-experimenter.md       ← 🧪 Hypothesis Engine
├── hat-architect.md          ← ⚙️ System Designer
├── hat-debugger.md           ← 🧯 Failure Investigator
├── hat-refactor.md           ← 🧵 Clean-Up Engineer
├── hat-translator-plus.md    ← 🌐 Context-Aware Linguist
├── hat-writer.md             ← 🪶 Structured Content Engine
├── hat-clarifier.md          ← 🧾 Ambiguity Resolver
├── hat-strategist.md         ← 🧭 Decision Optimizer
├── hat-minimalist.md         ← 🧊 Compression + Efficiency
├── hat-forensic.md           ← 🔍 Deep Inspection
├── hat-homelab.md            ← 🧭 Systems Engineer
├── hat-automation.md         ← 🧱 Workflow Builder
└── hat-learning.md           ← 🧭 Skill Instructor

## 🧪 Experimental (see [[experimental/INDEX]])

| E1–E8 | [[experimental/INDEX\|Experimental Hats]] | Creative, unfiltered, adversarial, persona, brainstorm, tactical, socratic, social |

```
