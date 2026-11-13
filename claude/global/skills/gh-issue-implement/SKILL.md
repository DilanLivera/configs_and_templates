---
name: gh-issue-implement
description: Implement a whole GitHub issue on a branch by working through every unchecked task in its breakdown, one after another, using the gh-issue-task process for each, then open a pull request that closes the issue. Use when the user asks to implement, finish, or work through all tasks of a GH issue (e.g. "implement issue #11", "do all the tasks in issue #11").
---

# GitHub Issue Implementation

Runs `gh-issue-task` in a loop. `gh-issue-breakdown` produces the task list;
`gh-issue-task` defines how one task is implemented, reviewed, verified and
marked done. This skill repeats that for every unchecked task without
stopping between tasks.

## Process

1. **Find the breakdown comment.** `gh issue view <N> --comments`. The
   breakdown is the comment containing `## Implementation Tasks`. If none
   exists, stop and tell the user to run `/gh-issue-breakdown` first. If the
   user didn't supply `<N>`, ask.

2. **Create a branch.** From an up-to-date default branch, create
   `issue-<N>-<short-slug>` and do all the work on it. If you're already on
   a branch for this issue, keep using it.

3. **Work through the tasks in order.** For each unchecked task, follow
   steps 2 to 7 of `gh-issue-task` (`~/.claude/skills/gh-issue-task/SKILL.md`)
   exactly: implement, Opus sub-agent review, fix, full tests plus end-to-end
   verification, then tick the box and post the task summary comment.
   Re-read the breakdown comment before each task so you work from its
   current state.

4. **Keep going unless blocked.** Don't pause for approval between tasks.
   Stop and ask the user only when:
   - a review finding can't or shouldn't be fixed,
   - tests or end-to-end verification fail and the fix isn't clear,
   - the task needs a decision the breakdown and its listed decisions don't
     cover.

   When you stop, leave that task unchecked and report what's blocking.

5. **Open a pull request** once every task is checked. Push the branch and
   run `gh pr create` against the default branch. The title follows
   Conventional Commits and names the issue's outcome. The body opens with
   `Closes #<N>`, then lists each task with its commit SHA(s), in one line
   each.

6. **Post a final summary** on the issue with `gh issue comment <N> --body ...`
   linking the pull request in one or two sentences.

7. **Report back** with the URLs of the pull request, the breakdown comment
   and the final summary comment.

## What NOT to do

- **Don't weaken any `gh-issue-task` step** to go faster. Every task still
  gets its own review pass, full test run and end-to-end check.
- **Don't merge tasks** into one change or one commit.
- **Don't skip ahead** past a blocked task to later ones.
- **Don't open the pull request early** or with any task unchecked; the
  pull request closes the issue when it merges, so don't close it by hand.
- **Don't merge the pull request.** Review and merge are the user's call.
- **Don't edit task wording** in the breakdown beyond ticking checkboxes.
