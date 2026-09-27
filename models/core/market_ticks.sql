{{ config(cluster_by=['product_id', 'tick_ts']) }}

select
    snapshot_id,
    tick_ts,
    product_id,
    bid_price,
    bid_qty,
    ask_price,
    ask_qty,
    mid_price,
    spread,
    max_spread_since_start,
    avg_mid_price_1m,
    avg_mid_price_5m,
    avg_mid_price_15m,
    forecast_value,
    forecast_naive_value,
    forecast_model,
    forecast_status,
    forecast_target_ts,
    primary_aae_1m,
    primary_aae_5m,
    primary_aae_15m,
    naive_aae_1m,
    naive_aae_5m,
    naive_aae_15m,
    feed_status,
    feed_reason,
    data_age_ms,
    source_filename,
    loaded_at
from {{ ref('stg_coinbase__market_snapshots') }}
qualify row_number() over (partition by product_id, tick_ts order by loaded_at desc, source_filename desc) = 1
