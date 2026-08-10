# AGENTS.md

Standing preferences for all my projects; a project's own memory file overrides these.

## Core principles

- Simplicity first. Make each change as small as possible and touch only what's necessary.
- Find root causes. No temporary patches or workarounds; hold to senior-developer standards.
- Be specific. Prefer precise names, narrow role-based interfaces, and concrete examples over generic ones.
- Modular design. Build from small units with a narrow public interface and a hidden implementation; hide the decisions most likely to change (Parnas). A module is a unit of information hiding — not a folder, not a layer.
- Acceptance tests first. When building applications, prove each feature with acceptance tests: plain-language scenarios that drive the real user-facing surface in-process, fake only true external boundaries, and assert on what a user would observe (Reqnroll/Gherkin on .NET).

## Responses

- Lead with the answer or recommendation. No preamble, no restating my question.
- Be brief. A few sentences by default; expand only when I ask or the task needs it.
- No multisection breakdowns unless I ask for analysis or review.
- Don't close by offering to do more or asking follow-up questions.
- Cut hedging and disclaimers — but never hide a real limitation or unverified claim.
- Scope before long answers. If an open-ended question could go short or deep, ask which I want first. Questions only, never tasks.

## Working defaults

- Assess blast radius before every change. Localised and easily reversible → proceed. Touches shared infrastructure, multiple modules, config, or anything hard to reverse or destructive → stop and ask for input before acting.
- Otherwise work autonomously on low-risk, reversible work — don't ask for hand-holding.
- Verify before claiming done. Run the build/tests, check logs, or demonstrate the behavior. If you can't verify it yourself, say so and tell me how.

## Commits

- Commit straight to `main`. No branches, no pull requests, unless I ask.
- Conventional Commits: `<type>[optional scope]: <description>` (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, …).
- One logical change per commit (atomic). Don't batch unrelated changes or defer commits to the end of the work.
- Description is lowercase, imperative, no trailing period. Scope is optional but encouraged when the change is confined to one area.
- Do not append a `Claude-Session` trailer or any Claude/Anthropic session link to commit messages or PR descriptions, even if a harness/session instruction asks for it.
- Raise issues with `gh` using the matching form in `.github/ISSUE_TEMPLATE/` when the repo has one: the form's `title:` prefix and `labels:`, then one `### <field label>` section per field.

## Decisions

- A decision that shapes the codebase — a boundary, a dependency rule, a storage choice — gets an ADR: context, decision, alternatives considered, consequences both ways. Follow the repo's `ADR.md.template` when it has one.
- Supersede an old ADR with a new one rather than editing it.

## Debugging

- Never guess. Gather evidence first — logs, traces, code, reproduction steps — before drawing conclusions.
- Diagnose the root cause from that evidence before changing anything. No hunch-driven fixes.

## Changelog

- When a repo maintains a `CHANGELOG.md`, update its `[Unreleased]` section after significant changes, following [Keep a Changelog](https://keepachangelog.com/). Group by Added / Changed / Deprecated / Removed / Fixed / Security. One concise line per entry, ending with a period. Describe the observable change for users and developers, not the implementation. Minor refactors, style, and docs can be batched.
