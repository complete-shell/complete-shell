#------------------------------------------------------------------------------
# complete-shell - modern tab completion everywhere
# Copyright © 2019 Ingy döt Net <ingy@ingy.net>
# https://github.com/complete-shell/complete-shell
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# complete-shell standard library for git related completions
#------------------------------------------------------------------------------

# shellcheck shell=sh disable=2039,2154

# Branches, most recent first:
git-recent-branches() (
  _git-check || return 0

  git branch --sort=-authordate |
    cut -c 3- |
    grep "^$comp_word" |
    head -$((LINES -2))
)

_git-check() (
  [[ -d .git ]] || git rev-parse --git-dir 2> /dev/null &&
    return 0

  hint 'You are not in a Git repository directory'
  return 1
)
