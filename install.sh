#!/usr/bin/env bash
# Install dummygit: a single bash file into ~/.local/bin.
set -euo pipefail

RAW_URL="https://raw.githubusercontent.com/aiofsubhash/dummy-git/main/dummygit"
DEST_DIR="${DUMMYGIT_PREFIX:-$HOME/.local/bin}"

command -v curl >/dev/null 2>&1 || { echo "curl is required." >&2; exit 1; }
mkdir -p "$DEST_DIR"
curl -fsSL "$RAW_URL" -o "$DEST_DIR/dummygit"
chmod +x "$DEST_DIR/dummygit"

echo "Installed dummygit to $DEST_DIR/dummygit"
case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *)
    echo ""
    echo "$DEST_DIR is not on your PATH yet. Add this to ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"$DEST_DIR:\$PATH\""
    ;;
esac
echo ""
echo "One-time setup:   dummygit add personal"
echo "Then forever:     dummygit"
