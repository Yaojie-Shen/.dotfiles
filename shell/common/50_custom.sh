# Customization for each machine or internal environment; will not be included in the public repository.
#
# The custom scripts should be placed in:
# - ${HOME}/.persistent/custom.sh, or
# - ${HOME}/.persistent/custom/shell/*.sh
# and will be sourced automatically. As with shell/common, prefix filenames under
# custom/shell/ with a two-digit NN_ (e.g. 00_env.sh, 50_aliases.sh) to control load order.
if [[ -f "${HOME}/.persistent/custom.sh" ]]; then
    source ${HOME}/.persistent/custom.sh
elif [[ -d "${HOME}/.persistent/custom/shell" ]]; then
    for custom_shell in "${HOME}/.persistent/custom/shell/"*.sh; do
        . "${custom_shell}"
    done
fi
