#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



# shellcheck shell=bash disable=1090,2034,2154

#------------------------------------------------------------------------------
# This is the entry-point function for every completion and the only function
# that complete-shell adds to a shell environment. Its end-goal is to set the
# COMPREPLY variable and any compopt options. It reads these values from the
# stdout of the internal functions it calls.
#------------------------------------------------------------------------------
__complete-shell:compgen() {
  local comp_word=${COMP_WORDS[COMP_CWORD]}
  [[ $comp_word == '=' ]] && comp_word=
  printf -v compgen_file "%s/lib/%s/compgen.bash" \
    "$COMPLETE_SHELL_ROOT" \
    "$complete_shell_api_version"
  local compgen_func=compgen-$complete_shell_api_version

  local hints=()
  while true; do

    if [[ -d ${COMPLETE_SHELL_ROOT-} ]]; then
      local line comps=''
      while IFS=$'\n' read -r line; do
        if [[ $line =~ ^\$\  ]]; then
          eval "${line#\$\ }"
        elif [[ $line == \<HINT\>\ * ]]; then
          hints+=("${line#<HINT>\ }")
        else
          comps+="'$line' "
        fi
      done <<< "$(source "$compgen_file" && "$compgen_func" "$@")"

      [[ ${#hints[*]} -eq 0 ]] || break

      if [[ ${BASH_VERSINFO[0]} == '3' ]]; then
        COMPREPLY=()
        while IFS=$'\n' read -r line; do
          COMPREPLY+=("$line")
        done <<< "$(compgen -W "$comps" -- "$comp_word")"

      else
       IFS=$'\n' read -r -d '' -a COMPREPLY \
         <<< "$(compgen -W "$comps" -- "$comp_word")"
      fi

      if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
        if [[ ${COMPREPLY[0]} == *\ \ —\ * ]]; then
          COMPREPLY[0]=${COMPREPLY[0]%% *— *}
        fi

        [[ ${COMPREPLY[0]} != *= ]] &&
        [[ $(compopt 2>/dev/null) != *-o\ filenames* ]] &&
          COMPREPLY[0]+=' '

      else
        local i
        for ((i = 0; i < ${#COMPREPLY[*]}; i++)); do
          if [[ ${COMPREPLY[i]} == *—* ]]; then
            COMPREPLY[i]=$(
              printf "%-$((COLUMNS))s" "${COMPREPLY[i]}"
            )
          fi
        done
      fi

      bind 'set show-all-if-ambiguous on' 2>/dev/null
      bind 'set print-completions-horizontally on' 2>/dev/null
      compopt -o nosort 2>/dev/null

    else
      hints=(
        "CompleteShell not properly configured"
        "See: https://github.com/complete-shell/complete-shell/wiki/Bash-Setup"
      )
    fi

    break
  done

  if [[ ${#hints[*]} -gt 0 ]]; then
    COMPREPLY=()

    local hint
    for hint in "${hints[@]}"; do
      printf -v hint "%-${COLUMNS}s_" "$hint"
      COMPREPLY+=("${hint%_}")
    done

    COMPREPLY+=(' ')

    compopt -o nosort 2>/dev/null
  fi

  return 0
}

#------------------------------------------------------------------------------
# Completion debugging helper:
#------------------------------------------------------------------------------
if [[ ${COMPLETE_SHELL_DEBUG_TTY-} ]]; then
  XXX() {
    (echo ---; cat) > "${COMPLETE_SHELL_DEBUG_TTY:-/dev/null}"
  }
fi
