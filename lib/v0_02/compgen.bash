#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



# shellcheck shell=bash disable=1090,2034,2154

#------------------------------------------------------------------------------
# complete-shell v0.2 completion library
#
# Parse the current commandline state and call the appropriate completion
# functions.
#------------------------------------------------------------------------------
compgen-v0_02() {
  # XXX Temporarily only support completion when cursor is at eol
  [[ $COMP_POINT -eq ${#COMP_LINE} ]] || return 0

  # XXX Only support sane terminal width for now
  [[ $COLUMNS =~ ^[0-9]+$ && $COLUMNS -ge 40 ]] || return 0

  source "$COMPLETE_SHELL_ROOT/lib/array.bash"

  parse-command-line "$@" || return

  complete-option-names ||
  complete-option-values ||
  complete-sub-commands ||
  complete-arguments ||
  true
}

# Parse through the current command and set state variables:
parse-command-line() {
  comp_words=()
  comp_word=
  comp_prev=
  comp_third=
  comp_cmd=
  comp_scmd=
  comp_snum=0
  comp_copt=()
  comp_sopt=()
  comp_args=()

  local line=$COMP_LINE
  line=${line##\ }

  while [[ $line ]]; do
    [[ $line =~ ^([^[:space:]]+) ]] || {
      comp_words+=('')
      break
    }
    comp_words+=("${BASH_REMATCH[1]}")
    line=${line#${BASH_REMATCH[1]}}
    line="${line#"${line%%[![:space:]]*}"}"
  done

  [[ $COMP_LINE =~ [[:space:]]$ ]] && comp_words+=('')

  set -- "${comp_words[@]}"

  local i=$#
  comp_word=${!i}
  (( i > 2 )) && : $(( i-- )) && comp_prev=${!i}
  (( i > 2 )) && : $(( i-- )) && comp_third=${!i}

  unset 'sub_cmds[0]'

  local word='' opts=() count=0 i=0
  for word; do
    if [[ $((count++)) -eq 0 ]]; then
      comp_cmd=$word

    elif [[ $word == -* ]]; then
      opts+=("$word")

    elif [[ ${#sub_cmds[*]} -gt 0 && -z $comp_scmd ]] &&
      [[ $count -lt $# || -z $comp_word ]]
    then
      comp_scmd=$word
      comp_copt=("${opts[@]}")
      opts=()

      for ((i = 1; i < ${#sub_cmds[*]}; i++)); do
        if [[ $word == "${sub_cmds[i]}" ]]; then
          (( comp_snum = i ))
          break
        fi
      done

    else
      comp_args+=("$word")
    fi
  done

  # shellcheck disable=2034
  if [[ $comp_scmd ]]; then
    comp_sopt=("${opts[@]}")
  else
    comp_copt=("${opts[@]}")
  fi
}

hint() {
  echo "<HINT> $*"
}

complete-option-names() {
  [[ $comp_word =~ ^--?[^=]*$ ]] || return 1

  local on=opt_name ot=opt_type od=opt_desc
  if [[ $comp_scmd ]]; then
    on+=_$comp_snum
    ot+=_$comp_snum
    od+=_$comp_snum
  fi

  [[ ${!on} ]] || return 0

  local ona=$on'[@]' l=-1 n=''
  for n in "${!ona}"; do
    (( ${#n} > l )) && l=${#n}
  done
  local ots=$ot'[*]'
  [[ ${!ots} ]] && (( l++ ))

  local i=0 eq='' oti='' odi=''
  for o in "${!ona}"; do
    oti=$ot"[$i]"
    eq=''
    [[ ${!oti} ]] && eq='='

    odi=$od"[$i]"
    if [[ ${!odi} ]]; then
      printf "%-${l}s — %s\n" "$o$eq" "${!odi}"
    else
      echo "$o$eq"
    fi

    (( i++ ))
  done
}

complete-option-values() {
  [[ $comp_word =~ ^(--?[^=]+)=(.*)$ ]] || return 1

  comp_opt=${BASH_REMATCH[1]}
  comp_val=${BASH_REMATCH[2]}
  local comp_word=$comp_val

  local on=opt_name
  local ot=opt_type
  if [[ $comp_scmd ]]; then
    on+=_$comp_snum
    ot+=_$comp_snum
  fi
  local ons
  ons=$(Array.size "$ot")

  local i n
  for ((i = 0; i < ons; i++)); do
    oni=$on'[i]'
    if [[ $comp_opt == "${!oni}" ]]; then
      (( n = i ))
      break
    fi
  done

  [[ $n ]] || return 0

  local oti=${ot}"[$n]"

  local func=${!oti}

  local init_flags='-s'
  call-function "$func"
}

complete-sub-commands() {
  [[ ${#sub_cmds[*]} -gt 0 && -z $comp_scmd ]] || return 1

  l=-1
  for ((i = 1; i <= ${#sub_cmds[*]}; i++)); do
    (( ${#sub_cmds[i]} > l )) && l=${#sub_cmds[i]}
  done

  for ((i = 1; i <= ${#sub_cmds[*]}; i++)); do
    desc=cmd_desc_$i
    if [[ ${!desc} ]]; then
      printf "%-${l}s — %s\n" "${sub_cmds[i]}" "${!desc}"
    else
      printf "%s\n" "${sub_cmds[i]}"
    fi
  done

  return 0
}

complete-arguments() {
  local n=

  if [[ ${sub_cmds[*]} ]]; then
    set -- "${sub_cmds[@]:1}"
    for (( n = 1; n <= $#; n++)); do
      [[ $comp_scmd == "${!n}" ]] && break
    done
    [[ $n -le $# ]] || return 0
    n=_$n
  fi

  local var="arg_type$n"'[@]' func=
  [[ ${!var} ]] || return 0
  set -- "${!var}"

  index=${#comp_args[*]}
  func=${!index}

  [[ -z "$func" ]] &&
    [[ ${!#} == *+ ]] &&
    func=${!#}

  call-function "${func%+}"
}

call-function() {
  func=$1

  [[ $func ]] || return 0

  if [[ $func == *\ * ]]; then
    hint "$func"
    return 0
  fi

  : "${COMPLETE_SHELL_PATH:=${HOME:?}/.complete-shell}"
  : "${COMPLETE_SHELL_BASE:=${COMPLETE_SHELL_PATH##*:}}"
  : "${COMPLETE_SHELL_COMP:=$COMPLETE_SHELL_BASE/comp}"
  : "${COMPLETE_SHELL_CONFIG:=$COMPLETE_SHELL_BASE/config/bash}"
  : "${COMPLETE_SHELL_BASH_DIR:=$COMPLETE_SHELL_BASE/bash-completion/completions}"
  : "${COMPLETE_SHELL_TEMP:=$COMPLETE_SHELL_BASE/tmp}"
  : "${COMPLETE_SHELL_CACHE:=$COMPLETE_SHELL_BASE/cache}"

  local pattern=''
  if [[ $func =~ (.*)=(.*) ]]; then
    func=${BASH_REMATCH[1]}
    pattern=${BASH_REMATCH[2]}
  fi

  if [[ $func =~ ^\[(.*)\]$ ]]; then
    # shellcheck disable=2046,2086
    printf "%s\n" $(IFS=,; echo ${BASH_REMATCH[1]})
    return 0
  fi

  func1=__${complete_shell_package}__$func
  if command -v "$func1" &>/dev/null; then
    "$func1" || true
    return 0
  fi

  if [[ $func == *-* ]]; then
    local stdlib_path
    printf -v stdlib_path "%s/lib/%s/stdlib/%s.sh" \
      "$COMPLETE_SHELL_ROOT" \
      "$complete_shell_api_version" \
      "${func%%-*}"
    if source "$stdlib_path" 2>/dev/null; then
      if PATH='' command -v "$func" &>/dev/null; then
        "$func" || true
        return 0
      fi
    fi
  fi

  # shellcheck disable=1090
  source "$COMPLETE_SHELL_ROOT/lib/$complete_shell_api_version/stdlib.sh"
  if PATH='' command -v "$func" &>/dev/null; then
    "$func" || true
    return 0
  fi
}
