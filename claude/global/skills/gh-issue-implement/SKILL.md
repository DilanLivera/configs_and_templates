---
name: gh-issue-implement
description: Implement a whole GitHub issue on a branch by working through every unchecked task in its breakdown, one after another, then run one Opus review over all the changes and open a pull request that closes the issue. Use when the user asks to implement, finish, or work through all tasks of a GH issue (e.g. "implement issue #11", "do all the tasks in issue #11", "work on issue #11", "pick up issue #11").
---

# GitHub Issue Implementation

Companion to `gh-issue-breakdown`, which posts a numbered task list in an
issue comment under `## Implementation Tasks`. This skill implements and
verifies every task in that list, reviews all the changes once, and opens a
pull request.

## Standards

- **Simple and readable first.** When there's a choice, take the simplest,
  most readable code.
- **Production quality throughout.** Treat every line as production app
  code, including tests, scripts and anything that looks temporary.
- **Integration and acceptance tests only.** Prove each task with
  integration and acceptance tests; don't write unit tests.
- **Screenshots for UI work.** Capture the changed screens while verifying,
  save them outside the repo (the session scratchpad when there is one), and
  never commit them.
- **Note improvements.** Whenever you spot something that could make the
  work more efficient (a tool, a script, a process, a repo change), note it
  with what it would improve. Don't act on it; the user evaluates the list.

## Process

1. **Find the breakdown comment.** `gh issue view <N> --comments`. The
   breakdown is the comment containing `## Implementation Tasks`. If none
   exists, stop and tell the user to run `/gh-issue-breakdown` first. If the
   user didn't supply `<N>`, ask.

2. **Pick the base branch.** List remote branches matching `release/*`
   (`git ls-remote --heads origin 'release/*'`). One match is the base; none
   means the default branch is the base; more than one means stop and ask
   which to use.

3. **Create a branch.** From an up-to-date base branch, create
   `issue-<N>-<short_slug>` and do all the work on it. If you're already on
   a branch for this issue, keep using it.

4. **Work through the tasks in order.** Re-read the breakdown comment before
   each task so you work from its current state, then for the first
   unchecked task (`1. [ ]` … `N. [ ]`):
   - **Research with subagents.** Hand codebase exploration and research to
     subagents, one focused question each, so the main context stays small.
     Do trivial lookups yourself.
   - **Test first.** The task line is the spec; the part after the colon is
     its acceptance criterion. Write a failing acceptance or integration
     test for that criterion before the implementation.
   - **Implement** until the test passes, following the repo's `CLAUDE.md`
     conventions.
   - **Polish before committing.** Re-read the diff and ask whether there's
     a simpler, more elegant way; if anything feels hacky, redo it properly.
     Then commit, one logical change per commit.
   - **Verify.** Run the full test suite and confirm every test passes; a
     red or skipped suite is a stop. Then launch and drive the real app with
     the `/run` skill and reproduce the acceptance criterion; passing tests
     alone are not enough. If anything fails, fix it and verify again.
   - **Tick the box.** Flip `N. [ ]` to `N. [x]` in the breakdown comment
     with `gh api repos/{owner}/{repo}/issues/comments/{comment_id} -X PATCH
     -f body=...`, sending the full updated body. The comment id comes from
     step 1's output.
   - **Post a task summary** with `gh issue comment <N> --body ...`: one to
     three sentences on what changed, with the commit SHA(s).

5. **Never assume; the user makes every decision.** Don't pause for approval
   between tasks, but stop and ask whenever something isn't settled by the
   issue, the breakdown or its listed decisions: a design or naming choice,
   an unclear requirement, a choice between reasonable options, or a failure
   whose fix isn't clear. If you catch yourself thinking "I'll assume X",
   that's the signal to ask. Also ask when something looks off: if the
   codebase does something one way and you think that way is wrong, or you
   see it causing problems later, describe the concern and let the user
   choose instead of copying the pattern for consistency. Leave the task
   unchecked while you wait.

6. **Review once at the end.** When every task is checked, spawn the
   `claude` agent with `model: "opus"` to review `git diff <base>...HEAD`.
   Brief it with the issue number, the full task list, that diff range, and
   the repo conventions to check against (`CLAUDE.md`, and `docs/design.md`
   if present). Ask for every correctness issue, missed acceptance criterion
   and convention violation, each in one or two lines (file:line, what's
   wrong, why it matters), and tell it not to fix anything. Fix each finding
   and commit the fixes. If you disagree with a finding, or fixing it needs
   a decision, ask the user instead of choosing yourself. Then rerun the
   full test suite and the end-to-end checks for every task.

7. **Open a pull request.** Push the branch and run `gh pr create --base
   <base>`. The title follows Conventional Commits and names the issue's
   outcome. The body opens with `Closes #<N>`, then lists each task in one
   line each, then the review fixes.

8. **Report back** with the URLs of the pull request and the breakdown
   comment, plus the full paths of any screenshots so
   the user can attach them to the pull request, and the improvements you
   noted, one line each.

## What NOT to do

- **Don't make decisions for the user.** No assumptions, no "reasonable
  defaults"; ask.
- **Don't skip per-task verification.** Every task still gets the full test
  suite and an end-to-end check before its box is ticked.
- **Don't skip the final review**, and don't open the pull request with
  review findings unaddressed or verification failing.
- **Don't merge tasks** into one change or one commit.
- **Don't skip ahead** past a blocked task to later ones.
- **Don't close the issue by hand or merge the pull request.** Review and
  merge are the user's call.
- **Don't edit task wording** in the breakdown beyond ticking checkboxes.
