# Zplug configuration
source ~/.zplug/init.zsh
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# zplug "romkatv/powerlevel10k", as:theme, depth:1
zplug "zsh-users/zsh-autosuggestions", as:plugin, defer:2
zplug "zdharma/fast-syntax-highlighting", as:plugin, defer:2
zplug "conda-incubator/conda-zsh-completion", as:plugin, defer:2
if ! zplug check --verbose; then
    zplug install
fi
zplug load
