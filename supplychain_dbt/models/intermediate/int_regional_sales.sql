-- regional sales demand

select
    s.transaction_date,
    st.store_region,
    st.store_city,
    p.product_name,
    p.category as product_category,
    sum(s.quantity_sold) as total_units_sold,
    sum(s.sale_amount) as total_revenue,
    avg(s.discount_pct) as avg_discount_applied
from {{ ref('stg_sales') }} s
join {{ ref('stg_stores') }} st on s.store_id = st.store_id
join {{ ref('stg_products') }} p on s.product_id = p.product_id
group by 1, 2, 3, 4, 5