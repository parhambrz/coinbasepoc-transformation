---
name: dbt-performance
description: Diagnose slow dbt builds and Snowflake workload impact in this project using dbt artifacts, logs, and query history.
---

# dbt and Snowflake performance

Use this skill when builds are slow, Snowflake becomes unresponsive during dbt work, or Dynamic Table refreshes consume unexpected credits.

## Diagnose before tuning

1. Read the latest `logs/dbt.log` and `target/run_results.json`; identify whether the time is in dbt parsing, metadata discovery, model SQL, tests, queueing, warehouse startup, or Dynamic Table refresh.
2. Match Snowflake query IDs from the logs to query history. Compare `execution_time`, `queued_provisioning_time`, `queued_overload_time`, bytes scanned, partitions scanned, warehouse, and query text.
3. Confirm whether dbt actually started models. An interrupted build with empty `results` may have spent its entire runtime in a source test or warehouse queue.
4. For Dynamic Tables, inspect `SHOW DYNAMIC TABLES` and refresh history for the resolved refresh mode, refresh duration, lag, and failure reason. `AUTO` can resolve to full refresh.
5. Only then choose a change: remove redundant full-table tests, consolidate repeated staging scans, narrow the selected models/tests, change concurrency, or revise a query/materialization based on evidence.

## Project-specific cost controls

- Raw source records contain semi-structured JSON. A test or model that reads the full raw history can be much more expensive than its SQL text suggests.
- Do not reintroduce a raw-table `RAW_DATA IS NOT NULL` full scan. Required parsed fields are checked by the single staging contract test.
- Dev/CI/prod profiles use two dbt threads to limit concurrent work on the small Snowflake warehouses. Change this only with workload evidence.
- Core and mart Dynamic Tables use five-minute target lag and `AUTO` refresh mode. Target lag is a freshness objective, not a guarantee of refresh completion or incremental execution.
- Dynamic Tables refresh independently in Snowflake after dbt creates them. Include ongoing refreshes in cost/performance diagnosis, not just the interactive `dbt build` duration.
- Avoid adding clustering keys or increasing warehouse size without query-history evidence that supports the change.

Do not run repeated builds against prod to collect timing. Use dev or existing query history, and report when account-level monitoring privileges are needed to see the relevant diagnostics.
