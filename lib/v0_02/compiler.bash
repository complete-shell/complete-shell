# shellcheck shell=bash disable=1090,1091,2034

compiler:init() {
  PATH=${COMPLETE_SHELL_ROOT:?}/lib source 'array.bash'

  version='v0.2.6'
  api_version='v0_02'

  cmd_name=01
  cmd_desc=02
  opt_desc=03
  opt_name=04
  opt_type=05
  arg_desc=06
  arg_type=07
  sub_cmds=09

  parse-bash-function-files
}

N() {
  name=$1
  shift

  n=0
  num=0000

  unset "long_$num" "short_$num"

  desc=
  for arg; do
    case $arg in
      ..*) desc=${*#..}; break;;
      *) die "Unknown N argument '$arg'";;
    esac
  done

  set-value cmd_name "$name"
  set-value cmd_desc "$desc"
}

O() {
  local opts=() type='' desc=''

  for arg; do
    case $arg in
      --*) opts+=("$arg"); printf -v "long_$num" true; shift;;
      -*) opts+=("$arg"); printf -v "short_$num" true; shift;;
      =*) type=${arg#=}; shift;;
      ..*) desc=${*#..}; break;;
      @*) var="__complete_shell_var_${arg#@}"'[@]'; "${!var}";;
      *) die "Unknown O argument '$arg'";;
    esac
  done

  for opt in "${opts[@]}"; do
    push-value opt_desc "$desc"
    if [[ $opt =~ ^(.*)=(.*)$ ]]; then
      push-value opt_name "${BASH_REMATCH[1]}"
      push-value opt_type "${BASH_REMATCH[2]}"
    else
      push-value opt_name "$opt"
      push-value opt_type "$type"
    fi
  done
}

A() {
  for arg; do
    push-value arg_type "${arg#+}"
  done
}

C() {
  printf -v num "%04d" $((++n))

  local name=$1
  shift

  desc=
  for arg; do
    case $arg in
      ..*) desc=${*#..}; break;;
      @*) shift;;
      -*) O "$arg"; shift;;
      +*) A "$arg"; shift;;
      *) die "Unknown C argument '$arg'";;
    esac
  done

  set-value cmd_name "$name"
  set-value cmd_desc "$desc"
}

V() {
  if [[ $1 != @* ]]; then
    die "Invalid var def '$1' in 'V $*'." \
        "Var name must start with '@'."
  fi

  if [[ $2 != '=' ]]; then
    die "Invalid var def 'V $*'." \
        "Should be 'V $1 = ...'."
  fi

  var=__complete_shell_var_${1#@}
  shift 2

  IFS=' ' read -r -a "${var?}" <<< "$*"
}

parse-bash-function-files() {
  bash_function_code=
  bash_functions=()

  name=${COMPLETE_SHELL_SOURCE%.comp}
  name=${name##*/}

  while IFS='' read -r line; do
    if [[ $line =~ ^([-a-zA-Z0-9_]+)\(\) ]]; then
      bash_functions+=("__${name}__${BASH_REMATCH[1]}")
      bash_function_code+=__${name}__
    fi

    bash_function_code+="$line"$'\n'
  done <<< "$( cat \
    "${COMPLETE_SHELL_SOURCE%.comp}.sh" \
    "${COMPLETE_SHELL_SOURCE%.comp}.bash" \
    2>/dev/null
  )"
}


#------------------------------------------------------------------------------
emit-bash() {
  local var num kind value

  cat <<...
#! bash

# DO NOT EDIT - Generated by CompleteShell $version

# shellcheck disable=2034

_$name() {
  local complete_shell_version=$version
  local complete_shell_api_version=$api_version

  local complete_shell_package=$name

...

  if [[ ${#bash_functions[*]} -gt 0 ]]; then
    cat <<...
#------------------------------------------------------------------------------
$bash_function_code
#------------------------------------------------------------------------------

...
  fi

  prev=0
  while read -r line; do
    [[ $line =~ ^(_([0-9]{4})_[0-9]+_([a-z_]+))=(.*) ]] || continue

    var=${BASH_REMATCH[1]}
    num=${BASH_REMATCH[2]}
    nnnn=$num
    kind=${BASH_REMATCH[3]}
    value=${BASH_REMATCH[4]}
    [[ $num =~ ^0*(.*)$ ]] || die
    num=${BASH_REMATCH[1]}

    if [[ $kind == cmd_name && $num ]]; then
      comment=$'\n'"  # $num) $value"
      both=$(emit-bash-both)
      continue
    fi

    if [[ $num && $comment && $value ]]; then
      echo "$comment"
      comment=
      if [[ $both ]]; then
        echo "$both"
        both=
      fi
    fi

    if [[ $value =~ ^\( ]]; then
      var=$var'[*]'
      var=${!var}
      [[ $var ]] || continue
    else
      [[ $value ]] || continue
    fi

    echo "  local ${kind}${num:+_$num}=$value"

    emit-bash-both
  done <<< "$(
    set | grep -E '^_[0-9]{4}_[0-9]+_([a-z_]+)='
  )"

  cat <<...

  __complete-shell:compgen "\$@"
...
  if [[ ${#bash_functions[*]} -gt 0 ]]; then
    echo
    echo "  unset -f ${bash_functions[*]}"

  fi

  cat <<...
}

complete -o nospace -F "_$name" "\$(name="\${BASH_SOURCE[0]##*/}"; echo "\${name%.bash}")"
...
}

emit-bash-both() {
  if [[ $kind == cmd_name ]]; then
    vl=long_$nnnn
    vs=short_$nnnn
    if [[ ${!vl-} && ${!vs-} ]]; then
      echo "  local opt_both${num:+_$num}=true"
    fi
  fi
}

#------------------------------------------------------------------------------
set-value() {
  local name=$1 value=$2
  local var=_${num}_${!name}_$name
  printf -v "$var" "%s" "$value"

  if [[ $name == cmd_name ]]; then
    local num=0000
    push-value sub_cmds "$value"
  fi
}

push-value() {
  local name=$1 value=$2 num=$num
  local var=_${num}_${!name}_$name
  Array.push "$var" "$value"
}
