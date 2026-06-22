# AGENTS.md

Standing preferences for all my projects; a project's own memory file overrides these.

## Core principles

- Simplicity first. Make each change as small as possible and touch only what's necessary.
- Find root causes. No temporary patches or workarounds; hold to senior-developer standards.
- Be specific. Prefer precise names, narrow role-based interfaces, and concrete examples over generic ones.
- Modular design. Build from small units with a narrow public interface and a hidden implementation; hide the decisions most likely to change (Parnas). A module is a unit of information hiding — not a folder, not a layer.
- Acceptance tests first. When building applications, prove each feature with acceptance tests: plain-language scenarios that drive the real user-facing surface in-process, fake only true external boundaries, and assert on what a user would observe (Reqnroll/Gherkin on .NET).

## Working defaults

- Assess blast radius before every change. Localised and easily reversible → proceed.
  Touches shared infrastructure, multiple modules, config, or anything hard to reverse or
  destructive → stop and ask for input before acting.
- Otherwise work autonomously on low-risk, reversible work — don't ask for hand-holding.
- Verify before claiming done. Run the build/tests, check logs, or demonstrate the
  behavior. If you can't verify it yourself, say so and tell me how.

## Commits

- Conventional Commits: `<type>[optional scope]: <description>` (`feat`, `fix`, `refactor`,
  `docs`, `test`, `chore`, `ci`, …).
- One logical change per commit (atomic). Don't batch unrelated changes or defer commits
  to the end of the work.
- Description is lowercase, imperative, no trailing period. Scope is optional but encouraged
  when the change is confined to one area.

## Debugging

- Never guess. Gather evidence first — logs, traces, code, reproduction steps — before
  drawing conclusions.
- Diagnose the root cause from that evidence before changing anything. No hunch-driven fixes.

## Changelog

- When a repo maintains a `CHANGELOG.md`, update its `[Unreleased]` section after significant
  changes, following [Keep a Changelog](https://keepachangelog.com/). Group by Added /
  Changed / Deprecated / Removed / Fixed / Security. One concise line per entry, ending with
  a period. Describe the observable change for users and developers, not the implementation.
  Minor refactors, style, and docs can be batched.
