---
tags: [software, setup, reference]
aliases: [dev-setup, bootstrap, python-setup, git-config]
updated: 2026-06-15
---

# Development Setup

Python environment management, Git configuration, shell setup, and bootstrap process.

## Bootstrap Process

The [[dotfiles]] repo has two branches:
- **`main`** — Arch/CachyOS configs (pacman, paru, CUDA paths, CachyOS shell configs)
- **`deb`** — Debian 13 (Trixie) configs (apt, dpkg, textgen-bundled [[llama-server]])

```bash
# Clone a specific branch
git clone -b deb git@github.com:InnerTic/dotfiles.git ~/dotfiles
# Or switch branches later
cd ~/dotfiles && git checkout deb    # Debian
cd ~/dotfiles && git checkout main   # Arch
```

Then run `bootstrap.sh` to symlink configs into place:

```bash
cd ~/dotfiles && ./bootstrap.sh
```

What it creates:

| Source (in dotfiles repo) | Target | Purpose |
|---------------------------|--------|---------|
| `shell/.zshrc` | `~/.zshrc` | Zsh config with AI aliases |
| `shell/config.fish` | `~/.config/fish/config.fish` | Fish config with AI aliases + [[fastfetch]] greeting |
| `shell/fastfetch.jsonc` | `~/.config/fastfetch/config.jsonc` | [[fastfetch]] system info display (runs on terminal open) |
| `git/.gitconfig` | `~/.gitconfig` | Git user, aliases, diff settings |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Tmux config |
| `ssh/config` | `~/.ssh/config` | Host shortcuts (zima, pihole, etc.) |

Bootstrap only creates symlinks — it does not install packages or modify system files.
Run it after [[workspace-symlink-strategy|link-workspace.sh --apply]] so that workspace
symlinks are in place before config files land.

For a full reinstall, follow the numbered scripts in `vault/scripts/README.md` in order,
then run `bootstrap.sh` at step 5.

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
alias quickhelp='cat ~/dotfiles/docs/reference/quick-commands.txt'

# OpenCode
alias oc='opencode'
alias ocl='opencode --provider llama.cpp'
alias oclw='opencode web --provider llama.cpp'
```

See [[software/ai-tools/commands]] for the full AI command reference.

## OpenCode Setup

OpenCode config lives in `~/.config/opencode/opencode.json` (symlinked to workspace
via [[reference/workspace-symlink-strategy]]). Key providers configured:

- **llama.cpp** — local models on port 8080 (GPU 0) or 8081 (GPU 1)
- **OpenRouter** — cloud models via API key
- **OpenCode Zen** — free tier fallback

## Related

- [[software/ai-tools/commands]] — Full AI command reference
- [[reference/workspace-symlink-strategy]] — What persists across reinstalls
- [[reference/glossary]] — Term [[glossary]]
