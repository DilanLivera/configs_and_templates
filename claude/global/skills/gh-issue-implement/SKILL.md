---
name: gh-issue-implement
description: Implement a whole GitHub issue on a branch by working through every unchecked task in its breakdown, one after another, then run one Opus review over all the changes and open a pull request that closes the issue. Use when the user asks to implement, finish, or work through all tasks of a GH issue (e.g. "implement issue #11", "do all the tasks in issue #11").
---

# GitHub Issue Implementation

Works through a whole `gh-issue-breakdown` task list. Each task follows
`gh-issue-task` (`~/.claude/skills/gh-issue-task/SKILL.md`) except for its
review, which this skill runs once at the end over every change.

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
   `issue-<N>-<short-slug>` and do all the work on it. If you're already on
   a branch for this issue, keep using it.

4. **Work through the tasks in order.** For each unchecked task, follow
   `gh-issue-task` steps 2, 3, 6 and 7: implement, full tests plus
   end-to-end verification, then tick the box and post the task summary
   comment. Skip its review and fix steps (4 and 5). Re-read the breakdown
   comment before each task so you work from its current state.

5. **Keep going unless blocked.** Don't pause for approval between tasks.
   Stop and ask the user only when:
   - tests or end-to-end verification fail and the fix isn't clear,
   - the task needs a decision the breakdown and its listed decisions don't
     cover.

   When you stop, leave that task unchecked and report what's blocking.

6. **Review once at the end.** When every task is checked, spawn the
   `claude` agent with `model: "opus"` to review `git diff <base>...HEAD`.
   Brief it as `gh-issue-task` step 4 describes, with the issue number and
   the full task list in place of a single task. Fix each finding and commit
   the fixes; if you disagree with one, say so in your reply to the user and
   skip it explicitly. Then rerun the full test suite and the end-to-end
   checks for every task.

7. **Open a pull request.** Push the branch and run `gh pr create --base
   <base>`. The title follows Conventional Commits and names the issue's
   outcome. The body opens with `Closes #<N>`, then lists each task with its
   commit SHA(s), in one line each, then the review fixes. A pull request
   into a `release/*` branch doesn't close the issue on merge, so tell the
   user it stays open until the change reaches the default branch.

8. **Post a final summary** on the issue with `gh issue comment <N> --body ...`
   linking the pull request in one or two sentences.

9. **Report back** with the URLs of the pull request, the breakdown comment
   and the final summary comment.

## What NOT to do

- **Don't skip per-task verification.** Every task still gets the full test
  suite and an end-to-end check before its box is ticked.
- **Don't skip the final review**, and don't open the pull request with
  review findings unaddressed or verification failing.
- **Don't merge tasks** into one change or one commit.
- **Don't skip ahead** past a blocked task to later ones.
- **Don't close the issue by hand or merge the pull request.** Review and
  merge are the user's call.
- **Don't edit task wording** in the breakdown beyond ticking checkboxes.
