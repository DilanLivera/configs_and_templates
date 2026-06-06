# Configs and Templates

A starter kit for new .NET projects. Copy what you need, configure once, and get consistent formatting, commit hygiene, and AI-assisted workflows out of the box.

## Project Docs

Templates so every project starts with the same documentation structure. Copy them into your project root and fill in the placeholders.

- [README.md.template](README.md.template) — project README scaffold with embedded agent instructions
- [CHANGELOG.md.template](CHANGELOG.md.template) — Keep a Changelog format
- [ADR.md.template](ADR.md.template) — Architecture Decision Record template

## Code Quality

Copy these into your project root — editors and git pick them up automatically.

- [.editorconfig](.editorconfig) — consistent formatting across C#, JS/TS, XML, and Markdown
- [.gitattributes](.gitattributes) — line ending normalization and binary file handling
- [.gitignore](.gitignore) — .NET/C# project ignores

## Git

Git hooks that enforce code quality and commit message standards. Copy the `.githooks/` directory into your project, then enable it:

```bash
git config core.hooksPath .githooks
```

- [pre-commit](.githooks/pre-commit) — runs `dotnet format` and `dotnet build` before each commit
- [commit-msg](.githooks/commit-msg) — enforces [Conventional Commits](https://www.conventionalcommits.org/) format

## AI Workflows

Cross-machine Claude Code configuration lives in [`claude/`](claude/) — global settings,
statusline, personal skills, and plugins. On a new machine, run `bash claude/install.sh`
to symlink it into `~/.claude/`. See [claude/README.md](claude/README.md) for details.

Two role-based workflows ship as Claude Code skills (synced via `claude/global/skills/`):

- `business-analyst` — requirements discovery; produces `REQUIREMENTS.md`
- `ddd-architect` — DDD design; produces `design.md` + `architecture-decision-records.md`
