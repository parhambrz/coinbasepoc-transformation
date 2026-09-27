---
name: snowflake-governance
description: Maintain Snowflake access boundaries, data lineage, environment separation, and consumer grants for this dbt project.
---

# Snowflake governance

Use this skill when changing roles, databases, schemas, source grants, consumer access, credentials, or data lineage practices.

## Environment boundaries

| Target | Database | Role | Warehouse | Schema pattern |
|---|---|---|---|---|
| Dev | `COINBASEPOC_DEV` | `ROLE_COINBASEPOC_DEV_PBARAZESH` (inherits `ROLE_COINBASEPOC_DEV`) | `WH_COINBASEPOC_DEV` | `DBT_<DEVELOPER>_<LAYER>` |
| CI | `COINBASEPOC_CI` | `ROLE_COINBASEPOC_CI` | `WH_COINBASEPOC_CI` | `PR_<NUMBER>_<LAYER>` |
| Prod | `COINBASEPOC_PROD` | `ROLE_COINBASEPOC_PROD` | `WH_COINBASEPOC_PROD` | `<LAYER>` |

The role grants permissions; `SNOWFLAKE_SCHEMA_DEV` chooses the developer namespace. The dev schema must match `DBT_<ID>` and the CI schema must match `PR_<positive number>`.

## Access rules

- Keep raw ingestion separate from dbt-owned databases. The raw table is read-only to dbt roles; the ingestion task owns writes to it.
- Dev roles write only to their developer schemas. CI writes only to PR schemas in the CI database. Prod writes only to production transformation schemas.
- Give consumers read-only access to approved production `CORE`, `MARTS`, and `SERVE` objects. Do not grant consumer access to raw, dev, or CI by default.
- Keep account-level provisioning and grant changes in the administrator-reviewed SQL template at `snowflake/admin/provision_environments.sql`. Never put admin credentials or broad grants in dbt workflows.
- Use key-pair authentication and GitHub secrets for CI/prod credentials. Never commit `profiles/profiles.yml`, private keys, passphrases, tokens, or generated credentials.
- Preserve `source_filename` and `loaded_at` as record-level lineage. Do not discard ingestion metadata without a reviewed alternative.

The SQL file is a template with placeholders; review and replace them before any administrator runs it. Read [architecture-and-governance.md](../../../docs/architecture-and-governance.md) for the full privilege model and source assumptions.
