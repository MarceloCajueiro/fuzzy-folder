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

# 3. Add source line to .zshrc.local if not already there
ZSHRC="$HOME/.zshrc.local"
SOURCE_LINE="source \"$INIT_FILE\""

if [[ -f "$ZSHRC" ]] && grep -qF "$INIT_FILE" "$ZSHRC"; then
  echo "  Already sourced in $ZSHRC"
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
