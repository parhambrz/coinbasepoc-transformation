select hour_ts, product_id
from {{ ref('spread_stats_hourly') }}
where tick_count <= 0 or minimum_spread < 0
