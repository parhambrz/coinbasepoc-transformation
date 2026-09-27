select forecast_snapshot_id
from {{ ref('forecast_accuracy') }}
where actual_at is not null
  and actual_at <> forecast_target_ts
