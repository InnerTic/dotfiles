# bootstrap-configs.sh

```bash
#!/bin/bash
# Extracted from: bootstrap.sh
# Single purpose: symlink dotfiles configs into place
# Usage: ./bootstrap-configs.sh [/path/to/dotfiles]

set -euo pipefail

DOTFILES="$(cd "${1:-${DOTFILES_DIR:-$HOME/dotfiles}}" && pwd)"

echo "Linking configs from $DOTFILES"

ln -sf "$DOTFILES/shell/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config/fish"
ln -sf "$DOTFILES/shell/config.fish" "$HOME/.config/fish/config.fish"
mkdir -p "$HOME/.config/fastfetch"
ln -sf "$DOTFILES/shell/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.ssh"
ln -sf "$DOTFILES/ssh/config" "$HOME/.ssh/config"

echo "Done. Restart your shell or source the config."
```
