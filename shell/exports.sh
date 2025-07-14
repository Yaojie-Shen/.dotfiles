export HYDRA_FULL_ERROR=1

# Set zsh history to persistent folder
export HISTFILE="${HOME}/.persistent/.zsh_history"

# Set huggingface cache to persistent folder
export HF_HOME="${HOME}/.persistent/cache/huggingface"
# Set pip cache dir to persistent folder
export PIP_CACHE_DIR="${HOME}/.persistent/cache/pip"
[ -d "$PIP_CACHE_DIR" ] || mkdir -p "$PIP_CACHE_DIR"
# Set conda cache dir to persistent folder
export CONDA_PKGS_DIRS="${HOME}/.persistent/cache/conda"
