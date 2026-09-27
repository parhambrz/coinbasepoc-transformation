---
name: dbt-modeling
description: Build or change dbt models in the Coinbase market data project, including source staging, core facts, marts, and serving views.
---

# dbt modeling for Coinbase market data

Use this skill when creating or changing transformation SQL, model configs, source definitions, or model documentation in this repository.

## Project conventions

- Follow the layers configured in `dbt_project.yml`: `staging` views normalize source fields, `core` Dynamic Tables define canonical grains, `marts` Dynamic Tables contain market/operational aggregates, and `serving` views provide stable consumer interfaces.
- Use lowercase model names with layer/domain prefixes where useful, such as `stg_coinbase__market_snapshots`.
- Keep ingestion-owned raw data unchanged. The default source is `COINBASEPOC.INGEST.RAW_STREAM`; its database, schema, and table are configurable through `COINBASE_RAW_DATABASE`, `COINBASE_RAW_SCHEMA`, and `COINBASE_RAW_TABLE`.
- Preserve `source_filename` and `loaded_at` through staging/core so downstream records retain blob and ingestion lineage.
- Parse JSON values with `TRY_TO_*` functions. Invalid values should become visible nulls and be reported by data quality tests rather than aborting an entire build.
- Keep the canonical tick grain one row per `product_id, tick_ts`. Core currently resolves duplicates by latest `loaded_at`; make any change to that policy explicit and test it.
- Dynamic Tables use a five-minute target lag and `AUTO` refresh mode. Do not claim that a five-minute target lag guarantees five-minute completion or incremental refresh; inspect Snowflake refresh mode/history when changing query shape.
- Use decimal types for prices and quantities. Clearly label derived approximations: order-book sizes support a quantity-weighted mid-price proxy, not trade VWAP.

## Workflow

1. Read the model's adjacent YAML and relevant upstream/downstream SQL before editing.
2. Keep one clear grain per model and document it in the model description.
3. Add or update YAML descriptions and tests for new fields and model keys.
4. Use `ref()` for project dependencies and `source()` for the raw ingestion relation.
5. Update `docs/architecture-and-governance.md` when a change affects source contracts, environment behavior, Dynamic Table refresh assumptions, or consumer guarantees.

See [README.md](../../../README.md) for project layers and local target setup, and [architecture-and-governance.md](../../../docs/architecture-and-governance.md) for source assumptions and reviewed design choices.
