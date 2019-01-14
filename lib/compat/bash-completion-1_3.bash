# shellcheck shell=bash disable=1090,2015

_init_completion() {
  :
}

if [[ ! -d ${COMPLETE_SHELL_ROOT:?}/lib/bash-completion ]]; then
  (
    cd "$COMPLETE_SHELL_ROOT" || exit 1

    git branch --track bash-completion origin/bash-completion &>/dev/null &&
    git worktree add lib/bash-completion bash-completion &>/dev/null ||
    git clone --quiet --branch=bash-completion .git lib/bash-completion &>/dev/null
  )
fi

source "$COMPLETE_SHELL_ROOT/lib/bash-completion/init_completion.bash" &>/dev/null
