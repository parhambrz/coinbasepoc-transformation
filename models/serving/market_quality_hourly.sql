select
    s.hour_ts,
    s.product_id,
    s.tick_count,
    s.average_spread,
    s.minimum_spread,
    s.maximum_spread,
    s.spread_stddev,
    s.average_mid_price,
    s.quantity_weighted_mid_price_proxy,
    coalesce(h.unhealthy_tick_count, 0) as unhealthy_tick_count,
    coalesce(h.data_age_p95_ms, 0) as data_age_p95_ms
from {{ ref('spread_stats_hourly') }} s
left join {{ ref('feed_health_log') }} h using (hour_ts, product_id)
