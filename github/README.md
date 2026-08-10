# GitHub Templates

Reusable GitHub repo configuration, kept here as a source of truth to copy into other
projects. The directory is deliberately named `github/`, not `.github/`, so GitHub does
**not** apply these to this repo — they're templates, not live config.

## Structure

```
github/
  ISSUE_TEMPLATE/
    feature.yml   New capability or behaviour change
    bug.yml       Observed vs expected, repro steps, evidence
    chore.yml     Maintenance, refactoring, tooling, docs
    config.yml    Issue chooser settings
```

## Use in a project

```bash
mkdir -p .github
cp -R /path/to/configs_and_templates/github/ISSUE_TEMPLATE .github/
```

GitHub picks the forms up once they're on the default branch — no other setup.

## Conventions

- **Titles are pre-filled with the matching Conventional Commit type** (`feat: `, `fix: `,
  `chore: `) so the issue title and the eventual commit line up.
- **Fields ask for the outcome and acceptance criteria, not the implementation.** That's
  what a breakdown pass needs to turn an issue into tasks without a round trip; file paths
  and patterns are the implementer's call.
- **Labels apply only if they already exist** in the target repo. `enhancement` and `bug`
  are GitHub defaults; create `chore` yourself, or drop the `labels:` line from
  `chore.yml`.
- `config.yml` sets `blank_issues_enabled: true`. Add `contact_links` there if a project
  needs to route questions elsewhere.