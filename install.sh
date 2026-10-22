#!/usr/bin/env bash
# install.sh - Install ff (fuzzy folder finder)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing ff..."

# 1. Create config if it doesn't exist
CONFIG_DIR="$HOME/.config/ff"
CONFIG_FILE="$CONFIG_DIR/config"
mkdir -p "$CONFIG_DIR"

if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<'EOF'
# ff config - search paths for fuzzy folder finder
# Format: path [depth=N]  (default depth: 2)
~/Code depth=2
EOF
  echo "  Created config at $CONFIG_FILE"
else
  echo "  Config already exists at $CONFIG_FILE"
fi

# 2. Patch the init script with the actual path
INIT_FILE="$SCRIPT_DIR/ff-init.zsh"
sed -i '' "s|__FF_SCRIPT_PATH__|$SCRIPT_DIR/ff.sh|g" "$INIT_FILE" 2>/dev/null || \
  sed -i "s|__FF_SCRIPT_PATH__|$SCRIPT_DIR/ff.sh|g" "$INIT_FILE"

# 3. Add source line to .zshrc.local if not already sourced
ZSHRC="$HOME/.zshrc.local"
SOURCE_LINE="source \"$INIT_FILE\""

# the init file may be referenced by absolute path or relative to $HOME
INIT_REL="${INIT_FILE#"$HOME"/}"
already_sourced_in=""
for rc in "$HOME/.zshrc" "$ZSHRC"; do
  if [[ -f "$rc" ]] && grep -qF -e "$INIT_FILE" -e "\$HOME/$INIT_REL" \
      -e "\${HOME}/$INIT_REL" -e "~/$INIT_REL" "$rc"; then
    already_sourced_in="$rc"
    break
  fi
done

if [[ -n "$already_sourced_in" ]]; then
  echo "  Already sourced in $already_sourced_in"
else
  echo "" >> "$ZSHRC"
  echo "# ff - fuzzy folder finder" >> "$ZSHRC"
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "  Added source line to $ZSHRC"
fi

echo ""
echo "Done! Restart your shell or run:"
echo "  source $INIT_FILE"
echo ""
echo "Usage: ff <pattern>"
echo "Config: $CONFIG_FILE"
