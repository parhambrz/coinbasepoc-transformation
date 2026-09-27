with forecasts as (
    select
        snapshot_id as forecast_snapshot_id,
        product_id,
        tick_ts as forecast_issued_at,
        forecast_target_ts,
        forecast_model,
        forecast_value,
        forecast_naive_value
    from {{ ref('market_ticks') }}
    where forecast_status = 'ready'
      and forecast_target_ts is not null
), matched as (
    select
        f.*,
        actual.mid_price as actual_mid_price,
        actual.tick_ts as actual_at
    from forecasts f
    left join {{ ref('market_ticks') }} actual
      on actual.product_id = f.product_id
     and actual.tick_ts = f.forecast_target_ts
)
select
    forecast_snapshot_id,
    product_id,
    forecast_issued_at,
    forecast_target_ts,
    actual_at,
    forecast_model,
    forecast_value,
    forecast_naive_value,
    actual_mid_price,
    abs(forecast_value - actual_mid_price) as primary_absolute_error,
    abs(forecast_naive_value - actual_mid_price) as naive_absolute_error,
    iff(sign(forecast_value - mid_at_issue.mid_price) = sign(actual_mid_price - mid_at_issue.mid_price), true, false) as primary_directional_hit,
    iff(sign(forecast_naive_value - mid_at_issue.mid_price) = sign(actual_mid_price - mid_at_issue.mid_price), true, false) as naive_directional_hit
from matched
left join {{ ref('market_ticks') }} mid_at_issue
  on mid_at_issue.product_id = matched.product_id
 and mid_at_issue.tick_ts = matched.forecast_issued_at
