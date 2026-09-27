select snapshot_id
from {{ ref('market_ticks') }}
where abs((ask_price - bid_price) - spread) > 0.000001
