---
name: gh-issue-task
description: Work on the next task in a GitHub issue breakdown — pick the next unchecked task, implement it, get an Opus sub-agent code review, fix the issues it raises, then mark the task done with a summary. Use when the user asks to work on / pick up / do the next task on a GH issue (e.g. "work on the next task in issue #11", "do task 2 of issue #11").
---

# GitHub Issue Task Execution

Companion to `gh-issue-breakdown`. That skill produces a numbered checklist in
an issue comment under `## Implementation Tasks`. This skill picks the next
unchecked task from that list, implements it, runs a review pass, and marks it
done.

## Process

1. **Find the breakdown comment.** `gh issue view <N> --comments`. The breakdown is the comment containing `## Implementation Tasks`. If none exists, stop and tell the user to run `/gh-issue-breakdown` first. If the user didn't supply `<N>`, ask.

2. **Pick the next task.** The first unchecked item (`1. [ ]` … `N. [ ]`) in that comment.

3. **Implement the change.** Treat the task line as the spec — the part after the em-dash is the acceptance criterion. Follow repo conventions from `CLAUDE.md`. Commit when the work is coherent; don't batch unrelated changes.

4. **Sub-agent review.** Spawn the `claude` agent with `model: "opus"` to review the diff. Brief it with:
   - the issue number and the exact task text
   - the diff range for this task (`git diff <base>..HEAD` — `<base>` is the commit before this task's first commit)
   - relevant repo conventions it should check against (point it at `CLAUDE.md` and `docs/design.md` if present)

   Ask for an issue list: correctness issues, missed acceptance criteria, convention violations. Each finding should be one or two lines — file:line + what's wrong + why it matters — not an essay. No total length cap; list every real issue. Do **not** ask it to fix anything.

5. **Fix the issues.** Address each item from the review. If you disagree with one, say so in your reply to the user and skip it explicitly — don't silently drop it. Commit the fixes.

6. **Verify — tests and end-to-end.** Final gate before marking done. Both are required; do not skip either.
   - **Run the full test suite** for the project and confirm all the tests pass. A red or skipped suite is a stop.
   - **End-to-end exercise the change** in the running app. Invoke the `/verify` skill (or `/run`) to launch and drive the app, then manually reproduce the task's acceptance criterion. The feature must demonstrably work in the real app — passing unit tests alone is not sufficient.

   If anything fails, fix it, review and re-verify. Do not advance to mark-done with a failing build, failing tests, or an unverified e2e flow.

7. **Mark the task done.**
   - Edit the breakdown comment to flip `N. [ ]` → `N. [x]` for this task.
     Use `gh api repos/{owner}/{repo}/issues/comments/{comment_id} -X PATCH -f body=...` with the full updated body. Get the comment id from step 1's output.
   - Post a new comment on the issue with `gh issue comment <N> --body ...` containing a 1–3 sentence summary of what changed and the commit SHA(s).

8. **Report back** to the user with the URLs of the updated breakdown comment and the summary comment.

## What NOT to do

- **Don't skip verification.** Both the full test suite and the end-to-end exercise are mandatory before marking the task done. "It compiles" and "unit tests pass" are not verification.
- **Don't skip the review pass** — even on small changes. The review loop is the reason this skill exists.
- **Don't mark a task done that isn't done.** If review surfaced issues you couldn't or wouldn't fix, leave the checkbox unchecked and explain what's blocking in your reply to the user. Do not post a "done" summary comment.
- **Don't open a PR** unless the user asks. Commit on the current branch and stop.
- **Don't bundle multiple tasks** into one pass. One task per invocation — the user can re-run the skill for the next.
- **Don't edit the breakdown comment's content** beyond toggling the checkbox. Task wording is the breakdown skill's responsibility.
