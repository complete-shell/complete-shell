#!/bin/bash

complete-shell-pager-fzf() {
  # shellcheck disable=2034
  local cur prev words cword
  _init_completion -n : || return 0

  local prompt=${COMP_LINE%$cur}
  prompt=${prompt%%\ }

  if [[ ${#prompt} -ge $(( $(tput cols) - 4 )) ]]; then
    prompt=${prompt:0:$(( $(tput cols) - 4 ))}
    prompt=${prompt%%\ }
    prompt=${prompt% *}...
  fi

  fzf_options+=("--prompt=$prompt " "--query=$cur")

  # shellcheck disable=2046
  set -- $(fzf "${fzf_options[@]}")
  [[ -z $1 ]] && shift

  if [[ $# -gt 0 ]]; then
    echo "$*"
    echo "$ comp_word=''"
  fi
}
