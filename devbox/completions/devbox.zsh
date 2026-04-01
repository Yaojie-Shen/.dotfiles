if [[ ! -o interactive ]]; then
    return
fi

compctl -K _devbox devbox

_devbox() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(devbox commands)"
  else
    completions="$(devbox completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}

compctl -K _housekeeper_ctl housekeeper_ctl

_housekeeper_ctl() {
  local words cword cur prev
  read -cA words
  cword=${#words}
  cur="${words[$cword]}"
  prev="${words[$cword-1]}"

  local -a commands opts
  commands=(pause enable disable auto monitor sleep)
  opts=(-h --help -s --socket -f --file --control-file -u --ui)

  if [[ "$prev" == "-u" || "$prev" == "--ui" ]]; then
    reply=(ansi line)
    return
  fi

  if [[ "$cur" == -* ]]; then
    reply=($opts)
    return
  fi

  if (( cword == 2 )); then
    reply=($commands)
    return
  fi

  # After subcommand (and possibly pause seconds), suggest global options.
  reply=($opts)
}
