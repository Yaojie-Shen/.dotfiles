# History
source "${HOME}/.shell/history.zshrc"

# Oh My Zsh
source "${HOME}/.shell/oh-my-zsh.zshrc"

# Plugins
source "${HOME}/.shell/plugins.zshrc"

# Devbox
source "${HOME}/.shell/devbox.zshrc"

# Aliases
source "${HOME}/.shell/aliases.sh"

# Exports
source "${HOME}/.shell/exports.sh"

# Functions
source "${HOME}/.shell/functions.sh"

# Custom
source "${HOME}/.shell/custom.sh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [ -d "${HOME}/miniconda3" ]; then
    __conda_setup="$('${HOME}/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
            . "${HOME}/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="${HOME}/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi
# <<< conda initialize <<<
