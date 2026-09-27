select
    date_trunc('hour', forecast_issued_at) as hour_ts,
    product_id,
    forecast_model,
    count(*) as forecasts_issued,
    count(actual_mid_price) as forecasts_with_actual,
    avg(primary_absolute_error) as primary_mean_absolute_error,
    avg(naive_absolute_error) as naive_mean_absolute_error,
    avg(iff(primary_directional_hit, 1.0, 0.0)) as primary_directional_accuracy,
    avg(iff(naive_directional_hit, 1.0, 0.0)) as naive_directional_accuracy
from {{ ref('forecast_accuracy') }}
group by 1, 2, 3
