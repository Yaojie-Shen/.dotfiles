# Set zsh history to persistent folder
export HISTFILE="${HOME}/.persistent/.zsh_history"

export HISTSIZE=100000
export SAVEHIST=100000

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history
