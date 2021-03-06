# shellcheck shell=bash disable=1090

# A function wrapper around `bin/complete-shell`:
complete-shell() {
  local comp

  local COMPLETE_SHELL_SHELL=bash
  local COMPLETE_SHELL_PATH=${COMPLETE_SHELL_PATH:-${HOME:?}/.complete-shell}
  local COMPLETE_SHELL_BASE=${COMPLETE_SHELL_BASE:-${COMPLETE_SHELL_PATH##*:}}
  [[ $COMPLETE_SHELL_BASE == "$COMPLETE_SHELL_ROOT" ]] && COMPLETE_SHELL_BASE+=/base
  local COMPLETE_SHELL_CONFIG=${COMPLETE_SHELL_CONFIG:-$COMPLETE_SHELL_BASE/config/$COMPLETE_SHELL_SHELL}
  local COMPLETE_SHELL_SRC=${COMPLETE_SHELL_SRC:-$COMPLETE_SHELL_BASE/src}
  local COMPLETE_SHELL_COMP=${COMPLETE_SHELL_COMP:-$COMPLETE_SHELL_BASE/comp}
  local COMPLETE_SHELL_BASH_DIR=${COMPLETE_SHELL_BASH_DIR:-$COMPLETE_SHELL_BASE/bash-completion/completions}

  local cmd=$1

  # Call the bin/complete-shell command:
  COMPLETE_SHELL_SHELL=$COMPLETE_SHELL_SHELL \
    "${COMPLETE_SHELL_ROOT:?}/bin/complete-shell" "$@" || return

  # Check for things to do in the local shell:
  local remake=$COMPLETE_SHELL_BASE/_remake
  if [[ -d $remake ]]; then
    # shellcheck disable=2046,2035
    set -- $(cd "$remake" && echo *)
    for comp; do
      rm -f "$COMPLETE_SHELL_BASH_DIR/$comp.bash"
      COMPLETE_SHELL_SHELL=$COMPLETE_SHELL_SHELL \
        "${COMPLETE_SHELL_ROOT}/bin/complete-shell" \
        compile \
        "$COMPLETE_SHELL_COMP/$comp.comp"
      unset -f "_$comp"
      complete -r "$comp" 2>/dev/null
    done

    rm -fr "$remake"
  fi

  local disable=$COMPLETE_SHELL_BASE/_disable
  if [[ -d $disable ]]; then
    # shellcheck disable=2046,2035
    set -- $(cd "$disable" && echo *)
    for comp; do
      unset -f "_$comp"
      complete -r "$comp" 2>/dev/null
    done

    rm -fr "$disable"
  fi

  local config=$COMPLETE_SHELL_BASE/_config
  if [[ -f $config ]]; then
    rm -f "$config"

    local line
    while read -r line; do
      bind "$line"
    done < "${COMPLETE_SHELL_CONFIG%/*}/.defaults"

    source "$COMPLETE_SHELL_ROOT/lib/config.bash" apply
  fi

  if [[ $cmd =~ ^(init|add|install)$ ]]; then
    if [[ ${BASH_VERSINFO[0]} == '3' ]]; then
      set -- "$COMPLETE_SHELL_BASE"/bash-completion/completions/*.bash
      for comp; do
        source "$comp"
      done
    fi
  fi
}
