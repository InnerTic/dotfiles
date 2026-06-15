---
tags: [software, setup, reference]
aliases: [dev-setup, bootstrap, python-setup, git-config]
updated: 2026-06-15
---

# Development Setup

Python environment management, Git configuration, shell setup, and bootstrap process.

## Bootstrap Process

The [[dotfiles]] repo provides a distro-agnostic `bootstrap.sh` that symlinks configs into place:

```bash
cd ~/dotfiles && ./bootstrap.sh
```

What it creates:

| Source (in dotfiles repo) | Target | Purpose |
|---------------------------|--------|---------|
| `shell/.zshrc` | `~/.zshrc` | Zsh config with AI aliases |
| `shell/config.fish` | `~/.config/fish/config.fish` | Fish config (if used) |
| `git/.gitconfig` | `~/.gitconfig` | Git user, aliases, diff settings |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Tmux config |
| `ssh/config` | `~/.ssh/config` | Host shortcuts (zima, pihole, etc.) |

Bootstrap only creates symlinks — it does not install packages or modify system files.
Run it after [[workspace-symlink-strategy|link-workspace.sh --apply]] so that workspace
symlinks are in place before config files land.

## Git Configuration

Global config lives in `git/.gitconfig`:

```ini
[user]
  name = InnerTic
  email = innertic@users.noreply.github.com
[alias]
  lg = log --oneline --graph --decorate -15
  a = add -A
  c = commit -m
  p = push
  s = status
  d = diff
```

Repository: `git@github.com:InnerTic/dotfiles.git`

## Python Virtual Environments

Python venvs on this system are managed per-project:

| Venv | Location | Purpose |
|------|----------|---------|
| openclaw | `/mnt/workspace/ocrenv/` | OpenClaw agent |
| textgen | `/workspace/textgen/` | TextGen WebUI (uses its own venv) |
| vllm | `/mnt/workspace/vllm_env/` | vLLM inference |
| openrouter | `/mnt/workspace/venv_openrouter/` | OpenRouter API tools |

Best practices:
- Keep venvs on `/mnt/workspace` (persists reinstalls)
- Never commit venv directories
- Use `pip install -r requirements.txt` for dependencies
- For CUDA projects, install torch with `pip install torch --index-url https://download.pytorch.org/whl/cu124`

## Shell Aliases

Defined in `shell/.zshrc` (auto-loaded via bootstrap):

```bash
# AI tools
alias llm='~/.local/bin/llama-loader'
alias llmcheck='curl -s http://127.0.0.1:8080/v1/models | jq -r .data[].id'
alias llmk='pkill -f llama-server'
alias llmstart='~/.openclaw/workspace/scripts/llama-start.sh'
alias textgen='~/.openclaw/workspace/scripts/textgen-start.sh'
alias textkill='pkill -f "server.py"'
alias quickhelp='cat ~/dotfiles/docs/quick-commands.txt'

# OpenCode
alias oc='opencode'
alias ocl='opencode --provider llama.cpp'
alias oclw='opencode web --provider llama.cpp'
```

See [[software/ai-tools/commands]] for the full AI command reference.

## OpenCode Setup

OpenCode config lives in `~/.config/opencode/opencode.json` (symlinked to workspace
via [[workspace-symlink-strategy]]). Key providers configured:

- **llama.cpp** — local models on port 8080 (GPU 0) or 8081 (GPU 1)
- **OpenRouter** — cloud models via API key
- **OpenCode Zen** — free tier fallback

## Related

- [[software/ai-tools/commands]] — Full AI command reference
- [[workspace-symlink-strategy]] — What persists across reinstalls
- [[reference/glossary]] — Term definitions
