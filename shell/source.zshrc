# Auto-discover and source every shell/zsh/*.zshrc and shell/common/*.sh file.
# The leading NN_ number in each filename controls load order (lower loads first);
# files sharing a number load in alphabetical order relative to each other.
for _shell_script in "${HOME}/.shell/zsh/"*.zshrc(N) "${HOME}/.shell/common/"*.sh(N); do
    source "${_shell_script}"
done
unset _shell_script
