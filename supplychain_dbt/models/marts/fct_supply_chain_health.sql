{{ config(
    materialized='table'
) }}

with stock_metrics as (
    select 
        transaction_date as report_date,
        store_region,
        store_city,
        product_id,
        product_name,
        product_category,
        stock_on_hand,
        reorder_threshold,
        total_units_sold,
        total_revenue,
        is_low_stock,
        -- Bringing in our new business intelligence metrics
        avg_daily_sales,
        inventory_cover_days,
        inventory_health_status
    from {{ ref('int_stock_vs_sales') }}
),

shipment_metrics as (
    select 
        -- Consistent date handling
        actual_delivery_date as report_date,
        product_name,
        avg(is_on_time) as avg_otd_rate,
        sum(quantity_shipped) as total_shipped
    from {{ ref('int_shipments_enriched') }}
    group by 1, 2
)

select
    i.report_date,
    i.store_region,
    i.store_city,
    i.product_id,
    i.product_name,
    i.product_category,
    i.stock_on_hand,
    i.avg_daily_sales,
    i.inventory_cover_days,
    i.inventory_health_status,
    i.reorder_threshold,
    i.total_units_sold,
    i.total_revenue,
    i.is_low_stock,
    -- Supplier Performance
    coalesce(s.avg_otd_rate, 0) as supplier_on_time_rate,
    coalesce(s.total_shipped, 0) as units_received_today
from stock_metrics i
left join shipment_metrics s 
    on i.product_name = s.product_name 
    and i.report_date = s.report_date

where i.report_date is not null


