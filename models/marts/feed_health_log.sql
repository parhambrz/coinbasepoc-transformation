select
    date_trunc('hour', tick_ts) as hour_ts,
    product_id,
    count(*) as unhealthy_tick_count,
    count_if(feed_status <> 'healthy') as non_healthy_tick_count,
    count_if(data_age_ms > {{ var('feed_latency_threshold_ms', 1000) }}) as latency_anomaly_count,
    approx_percentile(data_age_ms, 0.50) as data_age_p50_ms,
    approx_percentile(data_age_ms, 0.95) as data_age_p95_ms,
    approx_percentile(data_age_ms, 0.99) as data_age_p99_ms,
    min(tick_ts) as first_anomaly_at,
    max(tick_ts) as last_anomaly_at
from {{ ref('market_ticks') }}
where coalesce(feed_status, 'unknown') <> 'healthy'
   or data_age_ms > {{ var('feed_latency_threshold_ms', 1000) }}
group by 1, 2
