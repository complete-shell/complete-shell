# Set COMPLETE_SHELL_ROOT which is used throughout the framework:
{
  # If testing, honor our existing COMPLETE_SHELL_ROOT:
  if [[ $1 == test ]]; then
    : "${COMPLETE_SHELL_ROOT:=$(cd -P "$(dirname "$0")" && pwd)}"

  else
    COMPLETE_SHELL_ROOT=$(cd -P "$(dirname "$0")" && pwd)
  fi

  [[ $COMPLETE_SHELL_ROOT ]] || return 1
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
source "$COMPLETE_SHELL_ROOT/lib/complete-shell.zsh"
# Import the function called by all compdefs:
source "$COMPLETE_SHELL_ROOT/lib/compgen.zsh"

# Make sure the COMPLETE_SHELL_BASE directory is setup.
# This is where all the compdef files and your config file reside.
# This is typically ~/.complete-shell/  (default)
complete-shell init --quiet
