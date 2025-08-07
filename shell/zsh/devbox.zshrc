# Import devbox
export DEVBOX_ROOT=${DEVBOX_ROOT:-"$HOME/.devbox"}
[[ -d $DEVBOX_ROOT/libexec ]] && export PATH="$DEVBOX_ROOT/libexec:$PATH"
eval "$(devbox init -)"
source $DEVBOX_ROOT/completions/devbox.zsh
