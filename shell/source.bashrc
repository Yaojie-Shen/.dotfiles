# Auto-discover and source every shell/bash/*.bashrc and shell/common/*.sh file.
# The leading NN_ number in each filename controls load order (lower loads first);
# files sharing a number load in alphabetical order relative to each other.
_shell_nullglob_was_set=$(shopt -p nullglob)
shopt -s nullglob
for _shell_script in "${HOME}/.shell/bash/"*.bashrc "${HOME}/.shell/common/"*.sh; do
    source "${_shell_script}"
done
eval "${_shell_nullglob_was_set}"
unset _shell_script _shell_nullglob_was_set
