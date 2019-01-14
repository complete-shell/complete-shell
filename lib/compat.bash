#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



# shellcheck shell=bash disable=1090

#------------------------------------------------------------------------------
# For Bash we depend on the bash-completion framework, which generally is
# installed and available. See: https://github.com/scop/bash-completion
#
# There seems to be 3 popular versions: 1.3, 2.1 and 2.8. We attempt to detect
# the version here, and then load compatability libraries to make our API
# consistent.
#
# The detection criteria is currently simple, but will likely grow as usage
# grows to more unexpected situations.
#------------------------------------------------------------------------------

# All bash-completion versions define `_get_comp_words_by_ref`
if ! command -v _get_comp_words_by_ref >/dev/null; then
  cat <<...
You tried to enable complete-shell, but the basic Bash completion framework is
not installed/enabled.

See https://github.com/complete-shell/complete-shell/wiki/Bash-Setup for more
help on the matter.
...

  return 1
fi

# For 2.1+ set up XDG_DATA_DIRS with complete-shell for dynamic loading:
if command -v _init_completion &>/dev/null; then
  # Put COMPLETE_SHELL_PATH in XDG_DATA_DIRS for bash_completion auto load:
  __complete_shell_path=${COMPLETE_SHELL_PATH:-$HOME/.complete-shell}
  __complete_shell_xdg=${XDG_DATA_DIRS:=/usr/local/share:/usr/share}

  xdg_data_dirs=$XDG_DATA_DIRS
  if [[ $__complete_shell_xdg != *$__complete_shell_path:* ]]; then
    xdg_data_dirs=$__complete_shell_path:$__complete_shell_xdg
  fi

  unset __complete_shell_path __complete_shell_xdg
fi

# Check for bash-completion 2.6+
if [[ ${BASH_COMPLETION_VERSINFO[*]} == 2\ [6-9] ]] &&
   command -v __load_completion >/dev/null; then

  # Latest version. All good.

  export XDG_DATA_DIRS=$xdg_data_dirs
  unset xdg_data_dirs

  return 0
fi

# Check for bash-completion 1.3 (probably Mac)
if [[ ${BASH_COMPLETION-} ]] &&
   [[ -f /usr/local/etc/bash_completion ]]; then

  source "$COMPLETE_SHELL_ROOT/lib/compat/bash-completion-1_3.bash"

  export XDG_DATA_DIRS=$xdg_data_dirs
  unset xdg_data_dirs

  return 0
fi

# Check for bash-completion 2.1
if [[ ${BASH_COMPLETION_COMPAT_DIR-} ]] &&
   ! command -v __load_completion >/dev/null &&
   [[ -f /usr/share/bash-completion/bash_completion ]]; then

  source "$COMPLETE_SHELL_ROOT/lib/compat/bash-completion-2_1.bash"

  export XDG_DATA_DIRS=$xdg_data_dirs
  unset xdg_data_dirs

  return 0
fi

cat <<...
complete-shell depends on detecting your verion of the bash-completion
framework. Unfortunately we were unable to. Please file an issue here:

  https://github.com/complete-shell/complete-shell/issues

and we'll take care of you.

See https://github.com/complete-shell/complete-shell/wiki/Bash-Setup for more
help on the matter.
...

unset xdg_data_dirs

return 1
