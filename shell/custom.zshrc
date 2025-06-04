# Customization for each machine or internal environment, will not included in the public repository.
if [[ -f "${HOME}/.persistent/custom.sh" ]]; then
    source ${HOME}/.persistent/custom.sh
elif [[ -d "${HOME}/.persistent/custom" ]]; then
    for custom_shell in ${HOME}/.persistent/custom/*.sh; do
        source "${custom_shell}"
    done
fi