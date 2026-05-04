#!/usr/bin/env bash
# Symlinks global Claude Code settings from this repo into ~/.claude/
# Run once after cloning; subsequent edits to the repo files take effect immediately.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$REPO_DIR/global"
CLAUDE_DIR="$HOME/.claude"

symlink() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok $dst"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    echo "  backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -sf "$src" "$dst"
  echo "  linked $dst -> $src"
}

echo "Installing Claude global settings..."
mkdir -p "$CLAUDE_DIR"
symlink "$GLOBAL_DIR/settings.json"          "$CLAUDE_DIR/settings.json"
symlink "$GLOBAL_DIR/statusline-command.sh"  "$CLAUDE_DIR/statusline-command.sh"
echo "Done."
