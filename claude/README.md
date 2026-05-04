# Claude Code Configuration

## Structure

```
claude/
  global/
    settings.json           Global settings — symlinked to ~/.claude/settings.json
    statusline-command.sh   Status line script — symlinked to ~/.claude/statusline-command.sh
  install.sh                Installs global settings on a new machine
  settings.local.json       Template for project-level .claude/settings.local.json
```

## Setup on a new machine

```bash
bash claude/install.sh
```

Symlinks the global files into `~/.claude/`. Safe to re-run — existing symlinks pointing to
the correct target are left untouched; any pre-existing regular files are backed up first.

## Project settings

Copy `settings.local.json` into a new project as `.claude/settings.local.json` and adjust
the allowed commands for that project's stack. Only add things specific to the project —
anything that should apply everywhere belongs in `global/settings.json` instead.
