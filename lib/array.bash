# Array method library

# shellcheck shell=bash

Array.init() {
  ary=$1
  shift

  idx=0
  for elem; do
    Array.set "$ary" $((idx++)) "$elem"
  done
}

Array.get() {
  local ary="$1[$2]"
  echo "${!ary}"
}

Array.set() {
  IFS=$'\n' read -r "$1"[$2] <<< "$3"
}

Array.push() {
  idx=$(Array.size "$1")
  ary=$1
  shift

  for elem; do
    Array.set "$ary" $((idx++)) "$elem"
  done
}

Array.unshift() {
  ary=$1
  shift
  var="$ary"'[@]'
  set -- "$@" "${!var}"
  unset "$ary"
  for ((i = 1; i <= $#; i++)); do
    Array.set "$ary" "$((i - 1))" "${!i}"
  done
}

Array.pop() {
  (( idx = $(Array.size "$1") - 1 ))
  var="$1[$idx]"
  __=${!var}
  unset "$var"
}

Array.shift() {
  __=
  ary=$1
  shift
  var="$ary"'[@]'
  set -- "$@" "${!var}"
  [[ $# -gt 0 ]] || return
  __=$1
  shift
  unset "$ary"
  for ((i = 1; i <= $#; i++)); do
    Array.set "$ary" "$((i - 1))" "${!i}"
  done
}

Array.size() {
  local ary="$1[@]"
  set +u
  set -- "${!ary}"
  set -u
  echo $#
}

Array.first() {
  (($(Array.size "$1") - 1 >= 0)) || return 0
  ary="$1[0]"
  echo "${!ary}"
}

Array.last() {
  (( idx = $(Array.size "$1") - 1 ))
  ((idx >= 0)) || return 0
  ary="$1[$idx]"
  echo "${!ary}"
}

__unit-test() (
  die() { echo "$*" >&2; exit 1; }

  test() {
    echo "\$ $*"
    "$@"
    echo "size=$(Array.size a1)"
    # shellcheck disable=2154
    echo "indices=${!a1[*]}"
    echo "values=$(IFS=,; echo "${a1[*]}")"
    echo "first='$(Array.first a1)' last='$(Array.last a1)'"
    echo
  }

  test Array.init a1

  test Array.init a1 "f o o" "b a r"

  test Array.push a1 "b a z"

  test Array.shift a1

  test Array.push a1 "$__" "x y z"

  test Array.pop a1

  test Array.unshift a1 "$__" 'lu lu' lu

  test Array.push a1 "$(Array.get a1 1)"

  test Array.set a1 2 "O HAI"
)
