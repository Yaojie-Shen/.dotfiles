# Use zplug to manage zsh plugins automatically
source ~/.zplug/init.zsh

#####################
# Configure plugins #
#####################

# Async for zsh, used by pure theme
zplug "mafredri/zsh-async", from:github

zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2

zplug "zdharma/fast-syntax-highlighting", as:plugin, defer:2

zplug "conda-incubator/conda-zsh-completion", as:plugin, defer:2

################
# Color themes #
################

zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme

# P10k doesn't work out of the box, so I don't intend to use it by default.
# zplug "romkatv/powerlevel10k", as:theme, depth:1



# Check if all packages are installed, run installation if necessary.
if ! zplug check --verbose; then
    zplug install
fi
zplug load
