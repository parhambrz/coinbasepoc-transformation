---
name: dbt-git-workflow
description: Prepare, review, and commit changes to this dbt repository using Conventional Commits while keeping generated artifacts and credentials out of Git.
---

# Git workflow for the dbt project

Use this skill when preparing a dbt change for review, committing it, or checking what should be staged.

## Before staging

- Review `git status`, the full diff, and any new files. Stage only files relevant to the requested change.
- Keep `.venv/`, `target/`, `dbt_packages/`, `logs/`, `profiles/profiles.yml`, private keys, and local secrets out of commits; these paths are ignored for a reason.
- Include model SQL, model/source YAML, tests, macros, docs, workflow changes, `requirements.txt`, and `profiles/profiles.template.yml` only when they are part of the intended change.
- Check that changes to schemas, grants, environment names, and workflows agree across dbt config, profiles, docs, Snowflake admin SQL, and GitHub Actions.
- Run relevant dbt validation if requested or needed for the change, and accurately report what was and was not run.

## Conventional Commits

Use this message structure:

```text
<type>[optional scope][!]: <short imperative summary>

[optional body]

[optional footer(s)]
```

- Use a lowercase type. Prefer the types that best describe the change: `feat` (new capability), `fix` (bug fix), `perf` (performance), `test` (tests), `refactor` (behavior-preserving restructuring), `docs` (documentation), `ci` (automation), `build` (build/dependency tooling), and `chore` (maintenance).
- Add a short, lowercase scope when it clarifies the affected area, such as `models`, `staging`, `tests`, `governance`, `github-actions`, or `deps`.
- Keep the summary specific, concise, and imperative; omit the trailing period. Describe the change, not the work session.
- Add a body when context, rationale, or operational impact is not clear from the summary. Wrap lines reasonably and separate the body from the subject with a blank line.
- Mark a breaking change with `!` before the colon and explain it in the body, or include a `BREAKING CHANGE: ...` footer. Do not mark ordinary internal refactors as breaking.
- Add issue references or other meaningful trailers as footers when relevant. Do not invent issue IDs.

Examples:

```text
feat(marts): add hourly market quality model
fix(forecast): match predictions to target-time ticks
test(staging): validate snapshot keys and required fields
perf(models): reduce repeated scans of raw snapshots
ci(github-actions): isolate pull request schemas
docs(governance): clarify Snowflake role boundaries
build(deps): pin dbt adapter versions
refactor(core)!: change market tick grain to one row per venue and product

BREAKING CHANGE: downstream models must now include venue in their joins.
```

Choose the type according to the primary effect of the change. For a change spanning multiple areas, prefer one coherent commit or split it into focused commits when that makes review clearer.

## Commit behavior

- Commit only when the user asks for a commit or the task explicitly includes committing. Do not push, merge, or publish unless separately requested.
- Do not bundle unrelated local changes. If unrelated changes are present, leave them unstaged and mention them.
- After committing, report the commit hash and summarize the files or behavior included.