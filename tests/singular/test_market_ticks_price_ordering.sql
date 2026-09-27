select snapshot_id
from {{ ref('market_ticks') }}
where bid_price <= 0 or ask_price <= 0 or ask_price < bid_price
