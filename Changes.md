## v0.2.7   2019/01/30
- Fix a small mistake/typo

## v0.2.6   2019/01/30
- Use `COMPLETE_SHELL_BASE` instead of `COMPLETE_SHELL_PATH`
- `COMPLETE_SHELL_PATH` wil be a real PATH var for completion lookup

## v0.2.5   2019/01/29
- Support config file and settings
- Default to current Bash settings
- Make it easy to opt-in to new stuff

## v0.2.4   2019/01/16
- Fix #2 - Long completions display badly on OSX
- Fix shellcheck errors (upgraded to shellcheck 0.6.0)
- Add .rc and .bashrc to shellcheck testing
- Add --version to complete-shell comp file

## v0.2.3   2019/01/15
- Added `complete-prove` to index and removed `complete-shell`
- Fix issue #1 - Sub command completer blocking argument completion
- Fix issue #3 - Exclude 'complete-shell' from enable/disable/delete

## v0.2.2   2019/01/14
- Removed the config file concept
  - Not needed yet
  - Environment variables are simpler for this
- Set better readline defaults
  - Set them at init time. Better behavior.
  - Add minimal completion to compat/bash-completion-2.1 loader

## v0.2.1   2019/01/14
- Initial release
- Install/enable with `source .rc` or
  - `source .bashrc`
  - `source .zshrc`
  - `source .fishrc`
- Supports Bash completion so far
- Uses the most modern completion options your Bash version provides
- Extends https://github.com/scop/bash-completion
  - Usually installed on a system
  - Works with your installed version
  - Compatability fixes for older versions
  - Existing completions work as before
- Supports Bash 3.2+
  - Works on Mac (w/ Bash 3.2)
- Complete commands of forms:
  - `<cmd> [<option>...] [<argument>...]`
  - `<cmd> [<option>...] <sub-cmd> [<option>...] [<argument>...]`
- Support long and short options
- Options and arguments completed by reusable functions
  - Standard library of completion functions
    - Reuse standard bash-completion functions when available
    - Main stdlib has `file` and `dir` so far (with `xspec` support)
  - A compdef can define custom completion functions
- Compdef language supports:
  - `N` - completion name
  - `V` - reusable variable setting
  - `O` - option definition
  - `A` - argument definition
  - `C` - (sub) command definition
- Compiler compiles compgens to pure Bash
  - Custom functions are compiled into the bash
- Options and sub-commands can have descriptions
- Support showing descriptions during completion
- Added rudimentary `COMPLETE_SHELL_PATH/config` file for config
- Support 'hint completions' for errors and non-completables
- Comes with `complete-shell` CLI management command
  - Search, Install, Update compdefs
  - Disable/Enable them
  - Make completion aliases
  - Upgrade complete-shell
- State is stored in `~/.complete-shell/` (by default)
  - Override with `COMPLETE_SHELL_PATH`
- tmux based live demo test suite
  - Test pane - runs test suite
  - Output pane - completions happen live
  - Debug pane - optionally show debug info
- Requires terminal at least 40 columns wide
- Only supports completion at end of command line (for now)
