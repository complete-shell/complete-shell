# shellcheck shell=bash disable=1090

# Set COMPLETE_SHELL_ROOT which is used throughout the framework:
{
  # If testing, honor our existing COMPLETE_SHELL_ROOT:
  if [[ $1 == test ]]; then
    : "${COMPLETE_SHELL_ROOT:=$(
        cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

  else
    COMPLETE_SHELL_ROOT=$(
      cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  fi

  [[ $COMPLETE_SHELL_ROOT ]] || return 1
}

# Check current environment suitability and load any needed compat libs:
source "$COMPLETE_SHELL_ROOT/lib/compat.bash" || {
  unset COMPLETE_SHELL_ROOT
  echo
  echo 'complete-shell initialzation failed...'
  return 1
}

# Add complete-shell to PATH and MANPATH:
{
  if [[ $PATH != $COMPLETE_SHELL_ROOT/bin:* ]]; then
    PATH=$COMPLETE_SHELL_ROOT/bin:$PATH
  fi

  if [[ $MANPATH != *:$COMPLETE_SHELL_ROOT/man* ]]; then
    MANPATH=:$COMPLETE_SHELL_ROOT/man${MANPATH:+:$MANPATH}
  fi

  export COMPLETE_SHELL_ROOT PATH MANPATH
}

# Import the 'complete-shell' CLI wrapper function:
source "$COMPLETE_SHELL_ROOT/lib/complete-shell.bash"
# Import the function called by all compdefs:
source "$COMPLETE_SHELL_ROOT/lib/compgen.bash"

# Make sure the COMPLETE_SHELL_PATH directory is setup.
# This is where all the compdef files and your config file reside.
# This is typically ~/.complete-shell/  (default)
COMPLETE_SHELL_SHELL=bash \
  complete-shell init --quiet

# Save the current readline values before changing them:
bind -v |
  grep -E ' (print-completions-horizontally|completion-query-items|show-all-if-ambiguous|show-all-if-unmodified) ' \
  > "${COMPLETE_SHELL_PATH:-$HOME/.complete-shell}/.defaults"

source "$COMPLETE_SHELL_ROOT/lib/config.bash" apply
