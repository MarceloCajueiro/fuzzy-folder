#!/usr/bin/env bash
# ff - fuzzy folder finder
# Finds directories matching a fuzzy pattern and outputs the match.
# Designed to be used with a shell function that cd's into the result.

set -euo pipefail

VERSION="1.0.0"
CONFIG_FILE="${FF_CONFIG:-$HOME/.config/ff/config}"

# --- helpers ---

usage() {
  cat <<'EOF'
ff - fuzzy folder finder

Usage: ff <pattern>
       ff -l            List all indexed directories
       ff -e            Edit config file
       ff -v            Show version

Configuration: ~/.config/ff/config (or $FF_CONFIG)

Config format (one entry per line):
  path          -> searches direct children of path
  path depth=2  -> searches children up to depth 2

Example config:
  ~/Code
  ~/Code depth=2
  ~/projects
EOF
  exit 0
}

normalize() {
  # Lowercase, strip accents, remove hyphens/underscores/dots
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed 's/[-_.]//g' \
    | sed 's/[àáâãä]/a/g; s/[èéêë]/e/g; s/[ìíîï]/i/g; s/[òóôõö]/o/g; s/[ùúûü]/u/g; s/[ýÿ]/y/g; s/ñ/n/g; s/ç/c/g'
}

load_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" <<'DEFAULTCFG'
# ff config - one search path per line
# Optional: append depth=N to control search depth (default: 2)
# Examples:
#   ~/Code depth=2
#   ~/projects
DEFAULTCFG
    echo "Created default config at $CONFIG_FILE" >&2
    echo "Add your search paths and try again." >&2
    exit 1
  fi
}

collect_dirs() {
  local dirs=()

  while IFS= read -r line; do
    # skip comments and empty lines
    [[ -z "$line" || "$line" == \#* ]] && continue

    local search_path depth=2

    # parse "path depth=N"
    if [[ "$line" =~ ^(.+)[[:space:]]+depth=([0-9]+)$ ]]; then
      search_path="${BASH_REMATCH[1]}"
      depth="${BASH_REMATCH[2]}"
    else
      search_path="$line"
    fi

    # expand tilde
    search_path="${search_path/#\~/$HOME}"

    [[ ! -d "$search_path" ]] && continue

    # collect directories up to the specified depth
    while IFS= read -r d; do
      [[ -d "$d" ]] && dirs+=("$d")
    done < <(find "$search_path" -mindepth 1 -maxdepth "$depth" -type d \
      ! -name '.*' ! -path '*/.git/*' ! -path '*/node_modules/*' \
      ! -path '*/.next/*' ! -path '*/vendor/*' ! -path '*/__pycache__/*' \
      ! -path '*/.venv/*' ! -path '*/target/*' ! -path '*/.build/*' \
      2>/dev/null)

  done < "$CONFIG_FILE"

  printf '%s\n' "${dirs[@]}" | sort -u
}

fuzzy_match() {
  local pattern="$1"
  local normalized_pattern
  normalized_pattern="$(normalize "$pattern")"

  local matches=()

  while IFS= read -r dir; do
    local basename
    basename="$(basename "$dir")"
    local normalized_name
    normalized_name="$(normalize "$basename")"

    if [[ "$normalized_name" == *"$normalized_pattern"* ]]; then
      matches+=("$dir")
    fi
  done < <(collect_dirs)

  printf '%s\n' "${matches[@]}"
}

# --- main ---

[[ $# -eq 0 ]] && usage

case "${1:-}" in
  -h|--help) usage ;;
  -v|--version) echo "ff $VERSION"; exit 0 ;;
  -l|--list)
    load_config
    collect_dirs
    exit 0
    ;;
  -e|--edit)
    load_config
    "${EDITOR:-vi}" "$CONFIG_FILE"
    exit 0
    ;;
esac

load_config

pattern="$1"
matches=()

while IFS= read -r m; do
  [[ -n "$m" ]] && matches+=("$m")
done < <(fuzzy_match "$pattern")

count=${#matches[@]}

if [[ $count -eq 0 ]]; then
  echo "ff: no match for '$pattern'" >&2
  exit 1
elif [[ $count -eq 1 ]]; then
  echo "${matches[0]}"
else
  # multiple matches - use fzf if available, otherwise numbered list
  if command -v fzf &>/dev/null; then
    printf '%s\n' "${matches[@]}" | fzf --height=~50% --layout=reverse \
      --prompt="ff> " --header="Multiple matches for '$pattern'" \
      --preview='ls -la {}' --preview-window=right:40%
  else
    echo "Multiple matches for '$pattern':" >&2
    local i=1
    for m in "${matches[@]}"; do
      echo "  [$i] $m" >&2
      ((i++))
    done
    echo -n "Choose [1-$count]: " >&2
    read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
      echo "${matches[$((choice-1))]}"
    else
      echo "ff: invalid choice" >&2
      exit 1
    fi
  fi
fi
