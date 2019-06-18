#!/bin/bash

complete-shell-pager-selector() {
  # shellcheck disable=2034
  local cur prev words cword
  _init_completion -n : || return 0

  echo "$ comp_word='$cur'"

  grep "^$cur" | head -n2000
}
