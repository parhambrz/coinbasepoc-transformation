---
name: dbt-github-actions
description: Change or troubleshoot GitHub Actions workflows that build this dbt project in CI and deploy it to Snowflake production.
---

# dbt GitHub Actions

Use this skill when editing `.github/workflows`, configuring PR builds, handling CI schemas, or changing production deployment behavior.

## Current deployment contract

- `.github/workflows/dbt-ci.yml` runs for PRs targeting `master`, uses `ROLE_COINBASEPOC_CI`, and builds into `COINBASEPOC_CI.PR_<number>_<layer>`.
- `.github/workflows/dbt-ci-cleanup.yml` runs on PR close, checks out trusted `master` code, and drops only validated PR schemas.
- `.github/workflows/dbt-prod.yml` runs on pushes to `master`, which represents a merged PR, and builds into `COINBASEPOC_PROD` with the prod role.
- Keep dbt/dbt-snowflake versions aligned between `requirements.txt` and workflows.
- Keep actions read-only unless a workflow demonstrably needs more permissions. Use the protected `production` GitHub environment for production secrets.

## Required configuration

CI uses `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PRIVATE_KEY`, `SNOWFLAKE_ROLE_CI`, and `SNOWFLAKE_WAREHOUSE_CI`. Prod uses the matching prod role/warehouse configuration and protected environment secrets. Raw relation overrides are repository variables: `COINBASE_RAW_DATABASE`, `COINBASE_RAW_SCHEMA`, and `COINBASE_RAW_TABLE`.

Do not expose Snowflake secrets to fork PRs or execute untrusted PR code in a privileged cleanup/deploy workflow. The cleanup workflow must use trusted code from `master`, validate the PR schema name, and retain the cleanup macro's target/database guard.

Require the CI check in branch protection before merging. Production deployment occurs after merge and must not be changed to run against PR code. See [README.md](../../../README.md) for GitHub setup.
