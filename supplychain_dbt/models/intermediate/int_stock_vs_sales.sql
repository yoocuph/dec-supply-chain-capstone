{{ config(materialized='table') }} -- Making this a table improves my downstream performance

with daily_sales as (
    select
        transaction_date,
        product_id,
        store_id,
        sum(quantity_sold) as total_units_sold,
        sum(sale_amount) as total_revenue
    from {{ ref('stg_sales') }}
    group by 1, 2, 3
),

inventory_snapshots as (
    select
        snapshot_date,
        product_id,
        warehouse_id,
        quantity_available,
        reorder_threshold,
        is_low_stock
    from {{ ref('stg_inventory') }}
),

stores as (
    select 
        store_id,
        store_name,
        store_city,
        store_state,
        store_region,
        store_open_date
    from {{ ref('stg_stores') }}
),

enriched as (
    select
        s.transaction_date,
        st.store_region,
        st.store_city,
        p.product_name,
        p.product_id,
        i.quantity_available as stock_on_hand,
        i.reorder_threshold,
        i.is_low_stock,
        s.total_units_sold,
        s.total_revenue,
        p.category as product_category,
        -- 7-day Moving Average calculation
        avg(s.total_units_sold) over (
            partition by s.product_id, s.store_id 
            order by s.transaction_date 
            rows between 6 preceding and current row
        ) as avg_daily_sales
    from daily_sales s
    join {{ ref('stg_products') }} p on s.product_id = p.product_id
    left join inventory_snapshots i on s.product_id = i.product_id 
        and s.transaction_date = i.snapshot_date
    left join stores st on s.store_id = st.store_id
)

select
    *,
    safe_divide(stock_on_hand, avg_daily_sales) as inventory_cover_days,
    case 
        when safe_divide(stock_on_hand, avg_daily_sales) < 7 then 'CRITICAL'
        when safe_divide(stock_on_hand, avg_daily_sales) < 14 then 'WARNING'
        else 'HEALTHY'
    end as inventory_health_status
from enriched





-- select
--     s.transaction_date,
--     st.store_region,
--     st.store_city,
--     p.product_name,
--     p.product_id,
--     i.quantity_available as  stock_on_hand,
--     i.reorder_threshold,
--     i.is_low_stock,
--     p.category as product_category,
--     sum(s.quantity_sold) as total_units_sold,
--     sum(s.sale_amount) as total_revenue,
--     avg(s.discount_pct) as avg_discount_applied
-- from {{ ref('stg_sales') }} s
-- join {{ ref('stg_stores') }} st on s.store_id = st.store_id
-- join {{ ref('stg_products') }} p on s.product_id = p.product_id
-- join {{ ref('stg_inventory')}} i on s.product_id = i.product_id
-- group by 1, 2, 3, 4, 5, 6, 7, 8, 9