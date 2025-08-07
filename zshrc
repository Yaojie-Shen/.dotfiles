# Only source default config from ~/.shell/source.zshrc.
#
# This avoids Git conflicts when updating zshrc across machines, since system or tool-specific additions to .zshrc are
# kept separate in this file. All default settings (e.g. plugins, aliases, exports, etc.) are managed centrally in
# `~/.shell/source.zshrc`.
source "${HOME}/.shell/source.zshrc"
