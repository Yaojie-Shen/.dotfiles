proxy_on() {
  if [[ -z $1 ]]; then
    echo "Error: No proxy address provided."
    echo "Usage: proxy_on <proxy_address> [no_proxy_list]"
    return
  fi

  export HTTP_PROXY="$1"
  export HTTPS_PROXY=$HTTP_PROXY
  export FTP_PROXY=$HTTP_PROXY
  export SOCKS_PROXY=$HTTP_PROXY

  export NO_PROXY="${2:-localhost,127.0.0.1}"

  env | grep -e _PROXY | sort
  echo -e "\nProxy-related environment variables set."
}

proxy_off() {
  variables=(
    "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY" "SOCKS_PROXY" "NO_PROXY"
  )

  for i in "${variables[@]}"; do
    unset $i
  done

  env | grep -e _PROXY | sort
  echo -e "\nProxy-related environment variables removed."
}

source_env() {
  local scope="declare -x"

  print_help() {
    echo "Usage: source_env [OPTION]... FILE"
    echo "Load environment variables from FILE."
    echo
    echo "Options:"
    echo "  --local            Set variables in the local scope (default for functions)."
    echo "  --global           Export variables to the global environment (default)."
    echo "  --export           Use 'export' to set variables globally."
    echo "  --help             Display this help and exit."
    echo
    echo "FILE must contain key=value pairs, one per line."
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --local)
      scope="declare"
      shift
      ;;
    --global)
      scope="declare -x"
      shift
      ;;
    --export)
      scope="export"
      shift
      ;;
    --help)
      print_help
      return 0
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      print_help
      return 1
      ;;
    *)
      break
      ;;
    esac
  done

  local file="$1"
  if [[ -z "$file" || ! -f "$file" ]]; then
    echo "Error: File not found or not specified: $file" >&2
    print_help
    return 1
  fi

  echo "Environment variables loaded from '$file':"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    IFS='=' read -r key value <<<"$line"

    if [[ -n "$key" && -n "$value" ]]; then
      eval "$scope \"$key=\$value\""
      echo "$key=$value"
    else
      echo "Warning: Skipped invalid line: $line" >&2
    fi
  done <"$file"
}

# Run python script from url
# Usage:
#   python_from_url <url> <param-1> <param-2>...
python_from_url() {
  if [[ -z $1 ]]; then
    echo "Error: No url provided."
    echo "Usage: python_from_url <url> <param-1> <param-2> ..."
    return
  fi
  wget -qO- "$1" | python - "${@:2}"
}

lsl() {
  ls $@ | less
}

append_pythonpath() {
  if [[ -z $1 ]]; then
    export PYTHONPATH=$(pwd):$PYTHONPATH
    echo "Append $(pwd) to PYTHONPATH"
  else
    export PYTHONPATH="$PYTHONPATH:$1"
    echo "Append $1 to PYTHONPATH"
  fi
}

set_gpu() {
  export CUDA_VISIBLE_DEVICES=$1
  echo "Set CUDA_VISIBLE_DEVICES to $1"
}

unset_gpu() {
  unset CUDA_VISIBLE_DEVICES
  echo "Unset CUDA_VISIBLE_DEVICES"
}
