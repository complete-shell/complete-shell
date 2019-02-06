#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# complete-shell standard library
#------------------------------------------------------------------------------

# shellcheck shell=sh disable=2030,2031,2034,2039,2086,2154

str() {
  hint 'Enter a string'
}

cmd() (
  _command

  # Remove extra space from single completion:
  if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
    COMPREPLY[0]=${COMPREPLY[0]% }
  fi

  printf "%s\n" "${COMPREPLY[@]}"

  # Repeat compopt settings:
  while [[ $(compopt) =~ -o\ ([^\ ]+) ]]; do
    compopt +o "${BASH_REMATCH[1]}"
    echo "$ compopt -o ${BASH_REMATCH[1]}"
  done

  return 0
)

file() (
  if [[ ${pattern-} == \** &&
      $(type -t _filedir_xspec) == function
  ]]; then
    _xspecs[complete-shell-xspec]="!$pattern"
    _filedir_xspec complete-shell-xspec
  else
    _init_completion $init_flags && _filedir || return 0
  fi

  if [[ $comp_word != .* && $comp_word != */.* ]]; then
    set -- "${COMPREPLY[@]}"
    compreply=()
    for c; do
      [[ ${c##*/} == .* ]] || compreply+=("$c")
    done
  fi

  [[ ${#compreply[*]} -eq 0 ]] && return 0

  echo '$ compopt +o nospace 2>/dev/null || true'
  echo '$ compopt -o filenames 2>/dev/null || true'

  printf "%s\n" "${compreply[@]}" | sort | uniq
)

dir() (
  _init_completion $init_flags &&
  _filedir -d ||
  return 0

  if [[ $comp_word != .* && $comp_word != */.* ]]; then
    set -- "${COMPREPLY[@]}"
    COMPREPLY=()
    for c; do
      [[ ${c##*/} == .* ]] || COMPREPLY+=("$c")
    done
  fi

  [[ ${#COMPREPLY[*]} -gt 0 ]] || return 0

  # If only possible directory, add '/ ' after it:
  if [[ ${#COMPREPLY[*]} -eq 1 &&
        -z $(compgen -d "${COMPREPLY[0]}/")
  ]]; then
    COMPREPLY[0]+='/'
  else
    echo '$ compopt -o filenames 2>/dev/null || true'
  fi

  printf "%s\n" "${COMPREPLY[@]}"
)
