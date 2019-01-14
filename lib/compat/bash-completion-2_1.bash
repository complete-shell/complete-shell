#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



# shellcheck shell=bash disable=1090

#------------------------------------------------------------------------------
# Compatability code for bash-completion v2.1
#------------------------------------------------------------------------------

_completion_loader() {
  local cmd file files

  cmd=${1:-_EmptycmD_}
  cmd=${cmd##*/}

  IFS=$'\n' read -r -d '' -a files <<< "$(
    IFS=:
    # shellcheck disable=2086
    printf "%s/bash-completion/completions/$cmd.bash\n" $XDG_DATA_DIRS
  )"

  for file in "${files[@]}"; do
    source "$file" &>/dev/null && return 124
    source "${file%.bash}" &>/dev/null && return 124
  done

  # shellcheck disable=2154
  [[ ${_xspecs[$cmd]} ]] &&
    complete -F _filedir_xspec "$cmd" &&
    return 124

  return 1
}
