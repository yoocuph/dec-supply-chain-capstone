-- Product stockout trends & Warehouse efficiency
-- This models is expected to reveal what is running out of stock and where.

with inventory as (
    select * from {{ ref('stg_inventory') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
warehouses as (
    select * from {{ ref('stg_warehouses') }}
)

select
    i.snapshot_date,
    i.warehouse_id,
    w.warehouse_city,
    w.warehouse_state,
    i.product_id,
    p.product_name,
    p.category as product_category,
    i.quantity_available,
    i.reorder_threshold,
    i.is_low_stock,
    -- Enrichment: Calculate stock gap
    (i.reorder_threshold - i.quantity_available) as stock_deficit
from inventory i
left join products p on i.product_id = p.product_id
left join warehouses w on i.warehouse_id = w.warehouse_id