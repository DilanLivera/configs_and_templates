# Claude Code Configuration

Keeps global Claude Code config in version control so it can be synced across machines.

## Structure

```
claude/
  global/
    settings.json           Global settings — symlinked to ~/.claude/settings.json
    statusline-command.sh   Status line script — symlinked to ~/.claude/statusline-command.sh
    AGENTS.md               Global memory (tool-neutral) — symlinked to ~/.claude/CLAUDE.md
    skills/                 Personal skills — symlinked to ~/.claude/skills/
    hooks/                  Hook scripts — symlinked to ~/.claude/hooks/
    mcp-servers.json        User-scoped MCP servers to register (stdio)
    agents/                 Custom subagents (optional) — symlinked if present
    commands/               Custom slash commands (optional) — symlinked if present
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
- Registers the user-scoped MCP servers in `global/mcp-servers.json` via `claude mcp add`.

Safe to re-run — existing symlinks, marketplaces, plugins, and MCP servers are left untouched.

## Plugins and marketplaces

Plugin state is declared in `global/settings.json` and applied by `install.sh` — don't
install plugins ad-hoc via `/plugin`, or the live config will drift from the repo.

- `extraKnownMarketplaces` — each entry is a marketplace repo to register. **The key must
  match the marketplace's declared `name` in its `.claude-plugin/marketplace.json`, not the
  GitHub repo name** (e.g. `dotnet/skills` declares its name as `dotnet-agent-skills`). If
  two marketplaces declare the same name, they collide — `claude plugins marketplace add`
  will overwrite the existing entry rather than register a second one.
- `enabledPlugins` — each key is `<plugin>@<marketplace-name>` to install and enable.

Currently registered marketplaces:

| Marketplace key       | Repo            | Notes                                       |
| --------------------- | --------------- | ------------------------------------------- |
| `dotnet-agent-skills` | `dotnet/skills` | Official .NET team skills (all 13 plugins). |

To add a marketplace: add it under `extraKnownMarketplaces` keyed by its declared `name`,
add the plugins you want under `enabledPlugins`, then run `bash claude/install.sh`.

### `dotnet-agent-skills` LSP requirement: `dnx` on PATH

The `dotnet` plugin declares a C# Roslyn LSP server (`plugins/dotnet/lsp.json`) launched
via the bare command `dnx`. It needs:

- The **.NET 10 SDK** installed (ships the `dnx` tool runner).
- **`dnx` resolvable on PATH.** Some installs only symlink `dotnet` into `/usr/bin` and
  leave `dnx` under the SDK root (e.g. `/usr/lib/dotnet/dnx`), so bare `dnx` isn't found
  and the LSP server silently fails to launch. Fix by putting the SDK root on PATH, e.g.
  in `~/.profile`:

  ```sh
  if [ -x "/usr/lib/dotnet/dnx" ] ; then
      case ":$PATH:" in
          *":/usr/lib/dotnet:"*) ;;
          *) PATH="$PATH:/usr/lib/dotnet" ;;
      esac
  fi
  ```

  This is a machine-local shell change, not tracked by this repo. Verify with
  `bash -lc 'command -v dnx'`, then restart Claude Code so the spawned LSP inherits PATH.

## Hooks and portability

Don't hardcode machine-specific absolute paths in `settings.json` — route them
through a wrapper in `global/hooks/` (symlinked to `~/.claude/hooks/`) so the hook
command is a stable `$HOME/.claude/hooks/...` path that's identical on every machine.

`slack-notify.sh` is an example of the pattern (kept for reference, not currently
wired into `settings.json`): it locates the external `griffin` repo wherever it
lives — the parent dir name differs across machines, `repos` vs `repositories` —
or via `GRIFFIN_SLACK_NOTIFY`, and no-ops if griffin isn't installed. To enable it,
add a hook in `settings.json` with command `bash $HOME/.claude/hooks/slack-notify.sh`.

## Caveat: settings.json can drift

Claude Code sometimes saves settings via atomic write (temp file + rename), which
**replaces the `settings.json` symlink with a real file**. When that happens the
live config drifts from the repo. Re-running `install.sh` re-points the symlink
(backing up the live file first) — diff the backup against the repo to recover any
changes the UI made before discarding it.

Directory symlinks (`skills/`, etc.) don't have this problem: new files written
inside them land in the repo automatically.
