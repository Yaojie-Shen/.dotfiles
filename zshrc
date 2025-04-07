# Oh My Zsh
source "${HOME}/.shell/oh-my-zsh.zshrc"

# Zplug configuration
source ~/.zplug/init.zsh
# zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# zplug "romkatv/powerlevel10k", as:theme, depth:1
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug "zdharma/fast-syntax-highlighting", as:plugin, defer:2
# zplug "conda-incubator/conda-zsh-completion", as:plugin, defer:2
if ! zplug check --verbose; then
    zplug install
fi
zplug load

# Import devbox
# export DEVBOX_ROOT=${DEVBOX_ROOT:-"$HOME/.devbox"}
# [[ -d $DEVBOX_ROOT/libexec ]] && export PATH="$DEVBOX_ROOT/libexec:$PATH"
# eval "$(devbox init -)"
# source $DEVBOX_ROOT/completions/devbox.zsh

# Aliases
source "${HOME}/.shell/aliases.sh"

# Exports
# source "${HOME}/.shell/exports.sh"

# Functions
source "${HOME}/.shell/functions.sh"

# Customization for each machine or internal environment, will not included in the public repository.
if [[ -f "${HOME}/.shell/custom.sh" ]]; then
    source ${HOME}/.shell/custom.sh
fi

# Set zsh history to persistent folder
# export HISTFILE="${HOME}/.persistent/.zsh_history"
