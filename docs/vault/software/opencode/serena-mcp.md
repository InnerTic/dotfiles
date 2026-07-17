# Serena MCP — The IDE-Backed Semantic Toolkit for AI Agents

## TL;DR: Is Serena Worth It?

**YES — but only if you do heavy code refactoring.**

Reddit consensus: "Serena's IDE-backed semantic tools are the single most impactful addition to my toolkit."

**What it does:** Gives your OpenCode agent IDE-level understanding of code (cross-file renames, symbol lookups, safe refactors) instead of relying on brittle grep+regex.

**Cost:** ~15 min setup. No financial cost if using language servers (40+ languages supported).

**Best for:** Complex codebases, multi-file refactoring, symbol-aware navigation.

---

## What is Serena?

Serena is an **MCP server** (Model Context Protocol) that exposes IDE-level code manipulation tools to AI [[AGENTS]]. Think of it as "Language Server Protocol meets your AI agent."

Instead of your agent doing:
```bash
grep -r "function_name" . | wc -l  # Finds 47 matches
# Agent guesses which ones to rename
# Breaks 10 of them
```

With Serena, it does:
```
find_symbol("function_name")  # Finds 7 actual symbol references
rename_symbol("function_name", "new_name")  # Renames all 7 safely
# 0 breaks
```

### The Core Problem Serena Solves

**Without Serena:** [[AGENTS]] use grep/regex to find and edit code → false positives → broken code → manual fixes.

**With Serena:** [[AGENTS]] use IDE-level semantic understanding → correct, atomic operations → safe refactors.

---

## How It Works

Serena has **two backends:**

### 1. Language Server Backend (Free, Default)
Uses open-source language servers implementing the **Language Server Protocol (LSP)**.

**Supported:** 40+ languages
- AL, Ansible, Bash, C#, C/C++, Clojure, Crystal, Dart, Elixir, Elm, Erlang, Fortran, F#, GLSL, Go, Groovy, Haskell, Haxe, HLSL, Java, JavaScript, JSON, Julia, Kotlin, Lean 4, Lua, Luau, Markdown, MATLAB, mSL, Nix, OCaml, Perl, PHP, PowerShell, Python, R, Ruby, Rust, Scala, Solidity, Swift, TOML, TypeScript, WGSL, YAML, Zig

**Setup:** `serena init` (auto-installs language servers as needed)

**Pro:** Free, open-source, works offline, supports most languages.
**Con:** Less powerful than JetBrains for some languages.

### 2. JetBrains Backend (Paid, Optional)
Connects to a running JetBrains IDE (IntelliJ, PyCharm, WebStorm, etc.).

**Supported:** All languages JetBrains IDEs support (Java, Python, Kotlin, Go, Ruby, PHP, JavaScript, TypeScript, Scala, SQL, etc.)

**Setup:** Install plugin from JetBrains Marketplace + `serena init -b JetBrains`

**Pro:** More powerful refactors (inline, move, extract), better language support, IDE-backed accuracy.
**Con:** Paid ($80/year), requires JetBrains IDE running.

---

## Serena's Tools

### Retrieval (Find Code)
- **find_symbol** — Find a symbol by name (function, class, variable)
- **symbol_overview** — Show file outline (all symbols in a file)
- **find_referencing_symbols** — Find all usages of a symbol
- **search_in_project_dependencies** — Find symbols in imported projects (JetBrains only)
- **type_hierarchy** — Show class inheritance tree (JetBrains only)
- **find_declaration** — Jump to where symbol is defined (JetBrains only)
- **find_implementations** — Find all implementations of an interface (JetBrains only)
- **query_external_projects** — Search across multiple projects

### Refactoring (Change Code Safely)
- **rename** — Cross-file rename of symbols (or files/dirs with JetBrains)
- **move** — Move symbols/files between locations (JetBrains only)
- **inline** — Inline a variable or function (JetBrains only)
- **propagate_deletions** — Remove unused code after deletions (JetBrains only)

### Symbolic Editing (Low-Level Edits)
- **replace_symbol_body** — Replace function/method body atomically
- **insert_after_symbol** — Insert code after a symbol
- **insert_before_symbol** — Insert code before a symbol
- **safe_delete** — Delete symbol safely

### Debugging (JetBrains Only)
- **set_breakpoint** — Debug with REPL-style interface
- **inspect_variables** — Inspect state during execution
- **evaluate_expressions** — Run expressions in debugger
- **control_flow** — Step, resume, step-into execution

### Memory System
- Long-lived agent workflows
- Session-aware context management
- Integrates with OpenCode's `AGENTS.md` system

---

## Real-World Example

**Task:** Rename `get_user_data()` → `fetch_user_data()` across a large Python monorepo

### Without Serena
```bash
# Step 1: Find all matches
grep -r "get_user_data" . --include="*.py"
# Result: 47 matches

# Step 2: Agent reads each file and tries to determine which are actual uses
# Problem: Finds false positives:
#   - Comments mentioning "get_user_data"
#   - String literals with the name
#   - Different context where name happens to match
#   - Imports that don't matter

# Step 3: Agent uses regex to replace
sed -i 's/get_user_data/fetch_user_data/g' *.py

# Result: 3 files broken, API mismatch, string replacement destroyed a docstring
```

### With Serena
```python
# Step 1: Find the actual symbol
symbols = serena.find_symbol("get_user_data")
# Result: [
#   {symbol: "get_user_data", file: "api/user.py", type: "function", refs: 14},
# ]

# Step 2: Rename it
serena.rename("get_user_data", "fetch_user_data")
# Internally:
#   - Renames function definition
#   - Updates all 14 references across all files
#   - Updates imports in dependent modules
#   - Updates type hints where needed

# Result: 0 breaks, 1 atomic operation
```

---

## Installation & Setup

### Prerequisites
- `uv` (package manager) — [Install here](https://docs.astral.sh/uv/getting-started/installation/)
- For language server backend: Python 3.13+
- For JetBrains backend: JetBrains IDE running (IntelliJ, PyCharm, WebStorm, etc.)

### Quick Start (Language Server Backend)

```bash
# 1. Install Serena
uv tool install -p 3.13 serena-agent@latest --prerelease=allow

# 2. Initialize
serena init

# 3. Verify
serena --version
```

### OpenCode Integration

Add to your `opencode.json`:

```json
{
  "mcp": {
    "serena": {
      "command": "serena",
      "args": ["launch"]
    }
  }
}
```

Or if you prefer HTTP mode:

```json
{
  "mcp": {
    "serena": {
      "url": "http://localhost:8000",
      "env": {
        "SERENA_HTTP_PORT": "8000"
      }
    }
  }
}
```

Restart OpenCode and Serena tools will be available to the agent.

### JetBrains Backend (Optional)

```bash
# 1. Install IDE plugin
# - Open your JetBrains IDE
# - Go to Plugins → Browse Repositories
# - Search "Serena"
# - Install

# 2. Initialize with JetBrains backend
serena init -b JetBrains

# 3. Your opencode.json config stays the same
```

---

## When to Use Serena

### ✅ Use Serena If

- You do **cross-file refactoring** (renaming, moving code)
- Your codebase is **large or complex** (1000+ files, multiple language)
- You want **safe symbol operations** (not regex guessing)
- You work with **monorepos** (multi-project dependencies)
- You use Python, Java, TypeScript, or Go heavily (best language support)

### ❌ Skip Serena If

- You only do **simple file edits** (OpenCode's basic read/write is enough)
- Your codebase is **tiny** (<100 files, grep is fine)
- You never rename functions across files
- You're on a tight setup deadline (15 min is not nothing)

---

## Comparison: Serena vs. Alternatives

| Task | grep + regex | Serena (LS) | Serena (JB) | IDE Manual |
|------|--------------|------------|-----------|-----------|
| Find symbol usages | ❌ (false positives) | ✅ (100% accurate) | ✅ (100% accurate) | ✅ |
| Rename across files | ❌ (error-prone) | ✅ (atomic) | ✅ (atomic) | ✅ |
| Move code between files | ❌ | ❌ | ✅ | ✅ |
| Inline variable | ❌ | ❌ | ✅ | ✅ |
| Safe delete | ❌ | ✅ (symbols only) | ✅ (full) | ✅ |
| Language support | Any | 40+ | All JB supports | All JB supports |
| Setup complexity | 0 min | 5 min | 15 min | N/A |
| Cost | Free | Free | $80/year | Varies |

---

## Performance Impact

**Token efficiency:** Serena reduces refactoring operations from 8-12 steps down to 1 atomic call.

**Example:**
```
Without Serena:
1. grep to find references (5 results returned)
2. grep to filter for actual usages (3 results)
3. read file 1 to understand context
4. edit file 1
5. read file 2 to understand context
6. edit file 2
7. read file 3 to understand context
8. edit file 3
9. verify no breakage by running tests
10. find edge case you missed
= 10 steps, 50-100 tokens

With Serena:
1. find_symbol("old_name")
2. rename("old_name", "new_name")
= 2 steps, 10 tokens

Result: 80-90% token reduction on refactoring tasks
```

---

## Red Flags & Caveats

1. **Language support varies** — Language server backend has 40+ languages but some (like C, C++) have weaker support. JetBrains backend is more complete.

2. **Performance on huge monorepos** — Serena can be slow on 100K+ LOC projects. Start with language server backend if unsure.

3. **Not a substitute for testing** — Serena is very safe, but always run your test suite after major refactors.

4. **Configuration is complex** — Serena has many config options. Read the docs for your use case.

5. **JetBrains backend requires IDE running** — You need to keep your IDE open for the agent to use it.

---

## Bottom Line

**Serena is worth adding if:**
1. You do code refactoring (especially cross-file)
2. Your codebase is complex or large
3. You're already using OpenCode for real work

**It's not worth adding if:**
1. You only do simple edits
2. You're just experimenting with OpenCode
3. You're time-constrained and grep works fine

**Recommendation:**
- Start with **language server backend** (free, 5 min setup)
- If you hit limitations, upgrade to **JetBrains backend** ($80/year, 15 min setup)

---

## Resources

- **Docs:** https://oraios.github.io/serena/
- **GitHub:** https://github.com/oraios/serena
- **Video:** [Introduction to Serena in 5 Minutes](https://www.youtube.com/watch?v=5QN7gN1KYLA)
- **Discord:** https://discord.com/invite/cVUNQmnV4r

---

## Next Steps

1. **Decide on backend:** Language Server (free) or JetBrains (paid)?
2. **Install:** `uv tool install -p 3.13 serena-agent@latest --prerelease=allow`
3. **Initialize:** `serena init` (or `serena init -b JetBrains`)
4. **Configure OpenCode:** Add MCP config (see above)
5. **Test:** Ask agent to rename a function or move a file

