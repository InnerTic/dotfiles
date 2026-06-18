# SearXNG Setup

Self-hosted metasearch engine running as a user systemd service.

## Install (from scratch)

```bash
# Clone repo
git clone https://github.com/searxng/searxng.git /mnt/workspace/searxng/repo

# Create venv
uv venv /mnt/workspace/searxng/venv

# Install build deps + requirements
uv pip install --python /mnt/workspace/searxng/venv/bin/python pip setuptools wheel msgspec
uv pip install --python /mnt/workspace/searxng/venv/bin/python -r /mnt/workspace/searxng/repo/requirements.txt -r /mnt/workspace/searxng/repo/requirements-server.txt

# Install SearXNG package (needs --no-build-isolation — setup.py imports from searx at build time)
/mnt/workspace/searxng/venv/bin/pip install --no-build-isolation -e /mnt/workspace/searxng/repo

# Copy default config
cp /mnt/workspace/searxng/repo/searx/settings.yml /mnt/workspace/searxng/settings.yml
```

Customize `/mnt/workspace/searxng/settings.yml`:

- `server.secret_key` — generate with `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`
- `server.bind_address` — `"0.0.0.0"` for LAN access, `"127.0.0.1"` for local-only
- `server.limiter` — `false` for local use
- `search.formats` — add `json` for API access: 

  ```yaml
  formats:
    - html
    - json
  ```

## Service file

`~/.config/systemd/user/searxng.service`:

```
[Unit]
Description=SearXNG metasearch engine
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/mnt/workspace/searxng
Environment=SEARXNG_SETTINGS_PATH=/mnt/workspace/searxng/settings.yml
Environment=UV_LINK_MODE=copy
ExecStart=/mnt/workspace/searxng/venv/bin/searxng-run
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

## MCP Integration

MCP server bridges SearXNG to AI assistants (OpenCode, Claude, Cursor):

```bash
npm install --prefix /mnt/workspace/searxng/mcp mcp-searxng
```

Add to `~/.config/opencode/opencode.jsonc` (or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "searxng": {
      "command": "npx",
      "args": ["-y", "mcp-searxng"],
      "env": {
        "SEARXNG_URL": "http://127.0.0.1:8888"
      }
    }
  }
}
```

Provides tools: `searxng_web_search`, `searxng_search_suggestions`, `searxng_instance_info`, `web_url_read`.

## Commands

```bash
systemctl --user daemon-reload
systemctl --user enable --now searxng.service
systemctl --user status searxng.service
journalctl --user -u searxng.service -n 50 --no-pager
```

## Usage

- Web UI: http://127.0.0.1:8888
- JSON API: `curl 'http://127.0.0.1:8888/search?q=test&format=json'`
- OpenCode provider config: `"baseURL": "http://0.0.0.0:8888"`

## Directory layout

```
/mnt/workspace/searxng/
├── repo/              # git clone of searxng/searxng
├── venv/              # Python virtual environment
├── settings.yml       # custom config
```

## Notes

- Installed via pip (not AUR) to avoid sudo dependency and keep it as a user service
- Uses `--no-build-isolation` because setup.py imports `searx` (which requires `msgspec`) at import time during build
- No nginx reverse proxy needed for local-only usage — SearXNG's built-in server handles direct access on port 8888

## References

- SearXNG: <https://github.com/searxng/searxng>
- mcp-searxng (MCP bridge): <https://github.com/ihor-sokoliuk/mcp-searxng>
- SearXNG docs: <https://docs.searxng.org/>
