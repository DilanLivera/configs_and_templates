---
name: gh-issue-breakdown
description: Break a GitHub issue into a small task list and post it as a comment on the issue. Use when the user asks to break down, decompose, or plan tasks for a GH issue (e.g. "break down issue #11").
---

# GitHub Issue Task Breakdown

## Process

1. **Read the issue.** `gh issue view <N> --json title,body,labels,number,state`.
   Read any docs linked from the body.

2. **Research before listing.** For anything the issue touches (e.g. domain /
   contracts / app / UI / tests / docs) confirm what exists in the repo.
   Listing work that's already done is the most common mistake.

3. **Pause for input when uncertain.** Never guess. If anything is unclear —
   scope, design intent, choice between reasonable options, anything found
   mid-research that the issue doesn't address — stop and ask. If you catch
   yourself thinking "I'll assume X," that's the signal to ask instead.

4. **Draft using the structure below.** Don't invent a different one.

5. **Post the comment** with `gh issue comment <N>`.

6. **Share the URL and ask for review.**

## Output structure

Use a single numbered task list (GFM `1. [ ]`, `2. [ ]`, …). One block per
task — fold the acceptance criteria into the description with an em-dash;
do **not** use a separate "Acceptance:" line or `- [ ]` bullets.

    ## Implementation Tasks

    1. [ ] <deliverable in user/system terms> — <how we'll know it's done>.
    2. [ ] ...

    ## Out of scope

    - **Already in place** — <capability, plain-language>.
    - **Owned by issue #N** — <adjacent gap deferred>.

Omit `Out of scope` if it's empty — but you should have actively looked.

## What NOT to do

- **Don't start implementing.** The skill stops at posting the breakdown.
- **Don't guess file locations or assume docs match reality.** Verify.
- **Don't bundle adjacent gaps without flagging them.** Surface as a
  checkpoint question.
- **Don't include implementation details** (file paths, line numbers, code
  snippets, patterns to mirror). Those are decisions for the implementer.
