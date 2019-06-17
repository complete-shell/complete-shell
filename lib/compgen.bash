#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



# shellcheck shell=bash disable=1090,2034,2059,2154

#------------------------------------------------------------------------------
# This is the entry-point function for every complete-shell completion and the
# only function that complete-shell adds to your Bash environment. Its goal is
# to set the COMPREPLY variable and any compopt options. It reads these values
# from the stdout of the internal functions it calls.
#------------------------------------------------------------------------------
__complete-shell:compgen() {
  compopt -o nosort 2>/dev/null

  local hint padded="%-$((COLUMNS-2))s_"
  if [[ ! -d ${COMPLETE_SHELL_ROOT-} ]]; then
    printf -v hint "$padded" \
      "CompleteShell can't complete '${COMP_WORDS[0]}'. COMPLETE_SHELL_ROOT is undefined."
    COMPREPLY+=("$hint")
    printf -v hint "$padded" \
      "See: https://github.com/complete-shell/complete-shell/wiki/Bash-Setup"
    COMPREPLY+=("$hint")
    return
  fi

  # shellcheck disable=2046
  local $(source "$COMPLETE_SHELL_ROOT/lib/config.bash" vars)
  source "$COMPLETE_SHELL_ROOT/lib/config.bash" get

  $disabled && { _minimal; return; }

  # Hack to pretend command ends at cursor:
  {
    COMP_LINE=${COMP_LINE:0:$COMP_POINT}
    local ifs=$IFS
    IFS=$COMP_WORDBREAKS
    COMP_WORDS=($COMP_LINE)
    IFS=$ifs
    [[ $COMP_LINE =~ \ $ ]] && COMP_WORDS+=('')
    COMP_CWORD=$(( ${#COMP_WORDS[*]} - 1 ))
  }

  local comp_word=${COMP_WORDS[COMP_CWORD]}
  [[ $comp_word == '=' ]] && comp_word=

  local compgen_file
  printf -v compgen_file "%s/lib/%s/compgen.bash" \
    "$COMPLETE_SHELL_ROOT" \
    "$complete_shell_api_version"

  local compgen_func=compgen-$complete_shell_api_version

  local hints=()
  while true; do
    local line comps=''
    while IFS=$'\n' read -r line; do
      if [[ $line =~ ^\$\  ]]; then
        eval "${line#\$\ }"
      elif [[ $line == \<HINT\>\ * ]]; then
        hints+=("${line#<HINT>\ }")
      else
        line=${line//\'/\'\"\'\"\'}
        comps+="'$line' "
      fi
    done <<< "$(source "$compgen_file" && "$compgen_func" "$@")"

    [[ ${#hints[*]} -eq 0 ]] || break

    # Note: Bash 3.2 can't `read -a` here.
    COMPREPLY=()
    while IFS=$'\n' read -r line; do
      [[ $line ]] || continue
      COMPREPLY+=("$line")
    done <<< "$(compgen -W "$comps" -- "$comp_word")"

    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
      if [[ ${COMPREPLY[0]} == *\ —\ * ]]; then
        COMPREPLY[0]=${COMPREPLY[0]%% *— *}
      fi

      [[ ${COMPREPLY[0]} != *= ]] &&
      [[ $(compopt 2>/dev/null) != *-o\ filenames* ]] &&
        COMPREPLY[0]+=' '

    else
      local i
      for ((i = 0; i < ${#COMPREPLY[*]}; i++)); do
        if [[ ${COMPREPLY[i]} == *—* ]]; then
          if $show_descriptions; then
            COMPREPLY[i]=$(
              printf "%-$((COLUMNS))s" "${COMPREPLY[i]}"
            )
          else
            COMPREPLY[i]=${COMPREPLY[i]%% *— *}
          fi
        fi
      done
    fi

    break
  done

  if [[ $comp_word =~ (.*:) ]]; then
    COMPREPLY=("${COMPREPLY[@]#${BASH_REMATCH[1]}}")
  fi

  if [[ ${#hints[*]} -gt 0 ]] && $show_hints; then
    COMPREPLY=()

    local hint
    for hint in "${hints[@]}"; do
      printf -v hint "%-$((COLUMNS-2))s_" "$hint"
      COMPREPLY+=("${hint%_}")
    done

    COMPREPLY+=(' ')
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
