# Customization for each machine or internal environment; will not be included in the public repository.
#
# The custom scripts should be placed in:
# - ${HOME}/.persistent/custom.sh, or
# - ${HOME}/.persistent/custom/*.sh
# and will be sourced automatically.
if [[ -f "${HOME}/.persistent/custom.sh" ]]; then
    source ${HOME}/.persistent/custom.sh
elif [[ -d "${HOME}/.persistent/custom" ]]; then
    for custom_shell in "${HOME}/.persistent/custom/"*.sh; do
        . "${custom_shell}"
    done
fi