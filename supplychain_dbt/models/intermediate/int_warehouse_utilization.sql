-- Warehouse efficiency
-- This aggregates inventory levels by warehouse to see who is over-capacity or under-stocked

with inventory as (
    select * from {{ ref('stg_inventory') }}
)

select
    snapshot_date,
    warehouse_id,
    count(distinct product_id) as unique_products_stored,
    sum(quantity_available) as total_stock_on_hand,
    sum(case when is_low_stock then 1 else 0 end) as count_low_stock_items
from inventory
group by 1, 2