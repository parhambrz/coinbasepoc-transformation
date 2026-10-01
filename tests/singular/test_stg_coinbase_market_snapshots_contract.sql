with checked as (
    select
        snapshot_id,
        tick_ts,
        product_id,
        bid_price,
        ask_price,
        spread,
        feed_status,
        source_filename,
        loaded_at,
        count(*) over (partition by snapshot_id) as snapshot_id_count
    from {{ ref('stg_coinbase__market_snapshots') }}
)
select snapshot_id
from checked
where tick_ts is null
   or product_id is null
    or feed_status is null
   or source_filename is null
   or loaded_at is null
   or snapshot_id_count > 1
    or (
         feed_status = 'healthy'
         and (bid_price is null or ask_price is null or spread is null)
    )
