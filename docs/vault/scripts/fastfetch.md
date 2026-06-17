# fastfetch.jsonc

```jsonc
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "small",
        "padding": {
            "top": 1,
            "left": 34,
            "right": 4
        }
    },
    "display": {
        "separator": "  ",
        "color": {
            "separator": "bright_black"
        }
    },
    "modules": [
        "title",
        {
            "type": "custom",
            "format": "{#90}──────────────────────────────────────────"
        },
        {
            "type": "os",
            "key": "{#cyan}  OS"
        },
        {
            "type": "host",
            "key": "{#cyan}  Host"
        },
        {
            "type": "kernel",
            "key": "{#cyan}├   Kernel",
            "format": "{release}"
        },
        {
            "type": "packages",
            "key": "{#cyan}├   Packages",
            "combined": true
        },
        {
            "type": "shell",
            "key": "{#cyan}├   Shell"
        },
        {
            "type": "command",
            "key": "{#cyan}│   Tide",
            "text": "fish -c 'tide --version' 2>/dev/null | grep -oP 'version \\K[0-9.]+' || true"
        },
        {
            "type": "uptime",
            "key": "{#cyan}└   Uptime"
        },
        {
            "type": "cpu",
            "key": "{#green}  CPU",
            "showPeCoreCount": true,
            "temp": true
        },
        {
            "type": "gpu",
            "key": "{#green}├ 󰍛  GPU"
        },
        {
            "type": "command",
            "key": "{#green}│   VRAM",
            "text": "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader 2>/dev/null | awk -F', ' '{u=$1; gsub(/ MiB/,\"\",u); t=$2; gsub(/ MiB/,\"\",t); printf \"%s/%s MiB\\n\", u, t}' | paste -sd ' | ' || echo 'N/A'"
        },
        {
            "type": "memory",
            "key": "{#green}├   Memory"
        },
        {
            "type": "swap",
            "key": "{#green}├   Swap"
        },
        {
            "type": "disk",
            "key": "{#green}└   Disk",
            "folders": "/"
        },
        {
            "type": "de",
            "key": "{#yellow}  DE/WM"
        },
        {
            "type": "wm",
            "key": "{#yellow}├   WM"
        },
        {
            "type": "terminal",
            "key": "{#yellow}├   Terminal"
        },
        {
            "type": "terminalfont",
            "key": "{#yellow}├   Font",
            "format": "{/name}{-}{/}{name}"
        },
        {
            "type": "display",
            "key": "{#yellow}└ 󰍹  Display",
            "compactType": "original-with-refresh-rate"
        },
        {
            "type": "localip",
            "key": "{#magenta}󰩟  IP"
        },
        {
            "type": "sound",
            "key": "{#magenta}└   Audio"
        },
        "break",
        {
            "type": "command",
            "key": "{#red}  Python",
            "text": "python3 --version 2>/dev/null || python --version 2>/dev/null"
        },
        {
            "type": "command",
            "key": "{#red}  Node",
            "text": "node --version 2>/dev/null"
        },
        {
            "type": "command",
            "key": "{#red}  CUDA",
            "text": "nvidia-smi 2>/dev/null | grep 'CUDA Version' | grep -oP 'CUDA Version: \\K[0-9.]+' || nvcc --version 2>/dev/null | tail -1 | grep -oP 'release \\K[^,]+' || echo 'not installed'"
        },
        "break",
        {
            "type": "colors",
            "paddingLeft": 1,
            "symbol": "circle"
        }
    ]
}
```
