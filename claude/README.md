# Claude Code Configuration

Keeps global Claude Code config in version control so it can be synced across machines.

## Structure

```
claude/
  global/
    settings.json           Global settings — symlinked to ~/.claude/settings.json
    statusline-command.sh   Status line script — symlinked to ~/.claude/statusline-command.sh
    skills/                 Personal skills — symlinked to ~/.claude/skills/
    agents/                 Custom subagents (optional) — symlinked if present
    commands/               Custom slash commands (optional) — symlinked if present
    hooks/                  Hook scripts (optional) — symlinked if present
    CLAUDE.md               Global memory (optional) — symlinked if present
    keybindings.json        Keybindings (optional) — symlinked if present
  install.sh                Installs global config on a new machine
  .gitignore                Tripwire so secrets / session state can't be committed
```

## Setup on a new machine

```bash
bash claude/install.sh
```

It:
- Symlinks the global files/dirs above into `~/.claude/` (backing up any existing
  real files first). Optional items are linked only if they exist in the repo.
- Registers the marketplaces in `global/settings.json` (`extraKnownMarketplaces`).
- Installs the plugins listed under `enabledPlugins`.

Safe to re-run — existing symlinks, marketplaces, and plugins are left untouched.

## Caveat: settings.json can drift

Claude Code sometimes saves settings via atomic write (temp file + rename), which
**replaces the `settings.json` symlink with a real file**. When that happens the
live config drifts from the repo. Re-running `install.sh` re-points the symlink
(backing up the live file first) — diff the backup against the repo to recover any
changes the UI made before discarding it.

Directory symlinks (`skills/`, etc.) don't have this problem: new files written
inside them land in the repo automatically.
