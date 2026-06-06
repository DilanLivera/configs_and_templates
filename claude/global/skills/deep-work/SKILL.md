---
name: deep-work
description: Execute a substantial, multi-step task with full engineering rigor — plan into a checklist, fan research out to subagents, implement step-by-step with one atomic commit per step, do an elegance pass, and verify. Use when I explicitly ask to do something thoroughly / with rigor / "deep work", or for a meaty feature, refactor, or investigation. Skip for quick one-line fixes. Issue-agnostic — pair with gh-issue-task in issue-driven repos.
---

# Deep work — disciplined task execution

A heavier, opt-in process for substantial work. For quick, obvious fixes, skip it —
the global defaults already cover plan-first and verify-before-done.

## Process

1. **Plan first.** Break the work into small, verifiable steps as a checklist (write it
   to `tasks/todo.md` if the repo uses one). Check in with me before implementing.
2. **Fan out to subagents.** Offload research, exploration, and parallel analysis to
   subagents to keep the main context clean — one focused task per subagent. Don't spawn
   subagents for trivial work.
3. **Implement step by step.** Follow TDD when there's a testable runtime: failing test →
   implement → pass. Each step that changes code ends with one atomic commit before the
   next — the commit is the step's exit condition. Never batch logical changes or defer
   commits to the end.
4. **Demand elegance.** For non-trivial changes, pause and ask "is there a more elegant
   way?" If a fix feels hacky, redo it properly. Challenge your own work before presenting
   it. Skip this for simple changes.
5. **Review with fresh eyes.** Re-read the full diff before moving on — "would a staff
   engineer approve this?"
6. **Verify and summarize.** Prove it works (build, tests, logs, or observed behavior),
   then give a short summary of what changed at each step.
