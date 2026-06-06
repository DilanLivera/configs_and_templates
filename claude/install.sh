#!/usr/bin/env bash
# Symlinks global Claude Code settings from this repo into ~/.claude/ and installs
# the marketplaces + plugins declared in global/settings.json.
# Run once after cloning; subsequent edits to the repo files take effect immediately.
# Safe to re-run — existing symlinks, marketplaces, and plugins are left untouched.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$REPO_DIR/global"
SETTINGS="$GLOBAL_DIR/settings.json"
CLAUDE_DIR="$HOME/.claude"

symlink() {
  local src="$1"
  local dst="$2"

  # Only link what actually exists in the repo (optional files are skipped).
  if [ ! -e "$src" ]; then
    return
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ok $dst"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    echo "  backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -sfn "$src" "$dst"
  echo "  linked $dst -> $src"
}

echo "Installing Claude global settings..."
mkdir -p "$CLAUDE_DIR"

# Always-present files.
symlink "$GLOBAL_DIR/settings.json"          "$CLAUDE_DIR/settings.json"
symlink "$GLOBAL_DIR/statusline-command.sh"  "$CLAUDE_DIR/statusline-command.sh"

# Directories / files that sync only if present in the repo. Directory symlinks
# mean anything Claude Code writes there (e.g. a new skill) lands in the repo.
symlink "$GLOBAL_DIR/skills"                 "$CLAUDE_DIR/skills"
symlink "$GLOBAL_DIR/agents"                 "$CLAUDE_DIR/agents"
symlink "$GLOBAL_DIR/commands"               "$CLAUDE_DIR/commands"
symlink "$GLOBAL_DIR/hooks"                  "$CLAUDE_DIR/hooks"
# AGENTS.md is the canonical, tool-neutral memory file; Claude Code reads it via
# the ~/.claude/CLAUDE.md symlink. Point other agents at the same file as needed.
symlink "$GLOBAL_DIR/AGENTS.md"              "$CLAUDE_DIR/CLAUDE.md"
symlink "$GLOBAL_DIR/keybindings.json"       "$CLAUDE_DIR/keybindings.json"

# Register marketplaces declared under extraKnownMarketplaces before installing
# plugins — `claude plugins install` needs the marketplace registered first.
echo "Registering marketplaces..."
while IFS= read -r repo; do
  [ -z "$repo" ] && continue
  if claude plugins marketplace list --json 2>/dev/null | jq -e --arg r "$repo" '.[] | select(.repo == $r)' > /dev/null 2>&1; then
    echo "  ok $repo"
  else
    echo "  adding $repo"
    claude plugins marketplace add "$repo"
  fi
done < <(jq -r '(.extraKnownMarketplaces // {}) | to_entries[] | .value.source.repo // empty' "$SETTINGS")

# Register user-scoped MCP servers declared in global/mcp-servers.json. These
# write into ~/.claude.json (user scope) so they're available in every project.
# Only stdio servers are handled here; add others by hand if needed.
MCP_FILE="$GLOBAL_DIR/mcp-servers.json"
if [ -f "$MCP_FILE" ]; then
  echo "Registering MCP servers (user scope)..."
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    if claude mcp get "$name" > /dev/null 2>&1; then
      echo "  ok $name"
    else
      mapfile -t parts < <(jq -r --arg n "$name" '.[$n] | (.command, (.args[]?))' "$MCP_FILE")
      echo "  adding $name"
      claude mcp add --scope user "$name" -- "${parts[@]}"
    fi
  done < <(jq -r 'keys[]' "$MCP_FILE")
fi

echo "Installing plugins..."
while IFS= read -r plugin; do
  [ -z "$plugin" ] && continue
  if claude plugins list --json 2>/dev/null | jq -e --arg p "$plugin" '.[] | select(.id == $p)' > /dev/null 2>&1; then
    echo "  ok $plugin"
  else
    echo "  installing $plugin"
    claude plugins install "$plugin"
  fi
done < <(jq -r '(.enabledPlugins // {}) | keys[]' "$SETTINGS")

echo "Done."
