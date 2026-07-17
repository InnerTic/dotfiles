# dotfiles environment
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
