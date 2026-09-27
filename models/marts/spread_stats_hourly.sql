select
    date_trunc('hour', tick_ts) as hour_ts,
    product_id,
    count(*) as tick_count,
    avg(spread) as average_spread,
    min(spread) as minimum_spread,
    max(spread) as maximum_spread,
    stddev_samp(spread) as spread_stddev,
    avg(mid_price) as average_mid_price,
    sum(mid_price * (bid_qty + ask_qty)) / nullif(sum(bid_qty + ask_qty), 0) as quantity_weighted_mid_price_proxy
from {{ ref('market_ticks') }}
group by 1, 2
