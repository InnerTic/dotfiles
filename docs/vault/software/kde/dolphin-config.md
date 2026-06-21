# Dolphin Configuration — Reference Copy
# Restore: cp this file to ~/.config/dolphinrc
# After restore: run `kquitapp6 dolphin && dolphin` or log out/in
#
# Settings:
#   ShowHiddenFiles=true  — always show dotfiles (Ctrl+H / Alt+.)
#
# View mode (Details) is NOT stored here — it's stored as an extended
# attribute on ~/.local/share/dolphin/view_properties/global/.
# To set globally: View → Adjust View Display Style → View Mode: Details
# → check "Use as default view settings" → Apply to "All folders"
# Or from CLI after the first GUI set:
#   getfattr -d ~/.local/share/dolphin/view_properties/global

[General]
Version=202
ShowHiddenFiles=true

[KFileDialog Settings]
Places Icons Auto-resize=false
Places Icons Static Size=22
