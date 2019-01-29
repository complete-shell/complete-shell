# shellcheck shell=bash disable=1090,2034

config_keys=(
  disabled
  modern_settings
  single_tab
  no_prompt
  show_descriptions
  show_usage
  show_hints
  no_horizontal
)

if [[ ${1-} == vars ]]; then
  echo \
    config_file \
    config_keys \
    config_vals \
    "${config_keys[@]}"

  return
fi

get-config() {
  config_file=${COMPLETE_SHELL_CONFIG:-${COMPLETE_SHELL_PATH:-$HOME/.complete-shell}/config/bash}

  [[ -f $config_file ]] &&
    source "$config_file"

  config_vals=()
  local key
  for key in "${config_keys[@]}"; do
    config_vals+=("${!key}")

    [[ ${modern_settings-} == true &&
       $key == @(single_tab|no_prompt|show*) &&
       -z ${!key-}
    ]] && printf -v "$key" true

    [[ ${!key-} == @(true|false) ]] ||
      printf -v "$key" false
  done
}

# shellcheck disable=2154
apply-config() {
  local config_file config_vals "${config_keys[@]}"

  get-config

  $no_horizontal ||
    bind 'set print-completions-horizontally on' 2>/dev/null
  $no_prompt &&
    bind 'set completion-query-items 0' 2>/dev/null
  $single_tab && {
    bind 'set show-all-if-ambiguous on' 2>/dev/null
    bind 'set show-all-if-unmodified on' 2>/dev/null
  }

  unset config_keys
}

if [[ ${1-} == get ]]; then
  get-config
elif [[ ${1-} == apply ]]; then
  apply-config
fi

unset -f get-config apply-config
