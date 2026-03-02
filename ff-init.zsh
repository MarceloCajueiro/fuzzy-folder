# ff - fuzzy folder finder
# Source this file in your .zshrc to enable the ff command.
# Usage: ff <pattern>

ff() {
  local script="${FF_SCRIPT:-/Users/marcelo/Code/tools/fuzzy-folder/ff.sh}"

  if [[ $# -eq 0 || "$1" == -h || "$1" == --help || "$1" == -v || "$1" == --version || "$1" == -e || "$1" == --edit ]]; then
    "$script" "$@"
    return $?
  fi

  if [[ "$1" == -l || "$1" == --list ]]; then
    "$script" "$@"
    return $?
  fi

  local target
  target="$("$script" "$@")"
  local rc=$?

  if [[ $rc -eq 0 && -n "$target" && -d "$target" ]]; then
    cd "$target" && echo "-> $target"
  else
    return $rc
  fi
}
