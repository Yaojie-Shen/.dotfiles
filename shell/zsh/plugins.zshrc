# Use zplug to manage zsh plugins automatically
if [ -f /opt/homebrew/opt/zplug/init.zsh ]; then
    # Compatible with macOS (Homebrew on Apple Silicon)
    source /opt/homebrew/opt/zplug/init.zsh
elif [ -f /usr/share/zplug/init.zsh ]; then
    # Compatible with Linux install with package manager
    source /usr/share/zplug/init.zsh
elif [ -f ~/.zplug/init.zsh ]; then
    # Default installation path
    source ~/.zplug/init.zsh
else
    print "❌ Zplug not found, skipping plugin management.

👉 You can install it in one of the following ways:

1) macOS (Homebrew on Apple Silicon):
   brew install zplug
   # init.zsh will be at: /opt/homebrew/opt/zplug/init.zsh

2) Linux:
   apt install zplug
   # init.zsh will be at: /usr/share/zplug/init.zsh

3) Any system (official installer):
   curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
   # init.zsh will be at: ~/.zplug/init.zsh
"
    return 1
fi

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
