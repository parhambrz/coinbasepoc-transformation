---
name: dbt-testing
description: Design, implement, and troubleshoot dbt data quality tests for the Coinbase market data project.
---

# dbt tests and data quality

Use this skill when adding tests, changing model grain or source contracts, or diagnosing a failing or slow `dbt build`.

## Test design

- State the grain, then test the key for `not_null` and `unique` where uniqueness is an actual contract.
- Add relationship tests for cross-model keys, accepted values for controlled status fields, and singular SQL tests for business rules that generic tests cannot express clearly.
- Test derived market facts: bid/ask ordering, spread arithmetic, forecast target matching, and aggregate grain.
- Keep tests understandable and specific. A test should fail with rows that identify the violated contract.
- When changing a model, update both its adjacent schema YAML and any singular reconciliation tests affected by the change.

## Cost-aware checks

- Do not add broad generic tests directly to a large raw source without considering scan cost. In particular, `RAW_DATA IS NOT NULL` scans the raw table and is not the project's preferred check; test parsed required fields in staging instead.
- Avoid several independent full scans of the staging view when one singular test can check the same required-field contract in a single pass. The current staging contract test also checks duplicate snapshot IDs.
- Keep tests on compact marts when possible, and avoid tests that repeatedly re-read a large raw source unnecessarily.
- During diagnosis, inspect `target/run_results.json` for completed nodes and elapsed time, then correlate the Snowflake query IDs with query history. An empty `results` array can indicate an interrupted build rather than a successful or failed model test.
- Do not start repeated warehouse builds just to observe progress. Prefer existing logs/artifacts and query history; run a scoped build only when the user asks for validation or when it is necessary and authorized.

## Common commands

```bash
dbt build --target dev --profiles-dir profiles
dbt build --select stg_coinbase__market_snapshots --target dev --profiles-dir profiles
dbt test --select test_stg_coinbase_market_snapshots_contract --target dev --profiles-dir profiles
```

The dev target writes only to `COINBASEPOC_DEV`. Never point validation commands at `prod` unless the user explicitly requests a production operation.

See [architecture-and-governance.md](../../../docs/architecture-and-governance.md) for the contracts and target-time forecast matching rule.
