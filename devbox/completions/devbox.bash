_devbox() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(devbox commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]
    local completions=$(devbox completions "${words[@]}")
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _devbox devbox

_housekeeper_ctl_complete() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local commands opts
  commands="pause enable disable auto monitor sleep"
  opts="-h --help -s --socket -f --file --control-file -u --ui"

  case "$prev" in
    -s|--socket|-f|--file|--control-file)
      COMPREPLY=( $(compgen -f -- "$cur") )
      return 0
      ;;
    -u|--ui)
      COMPREPLY=( $(compgen -W "ansi line" -- "$cur") )
      return 0
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    return 0
  fi

  COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
  return 0
}

complete -F _housekeeper_ctl_complete housekeeper_ctl

