-- Supplier delivery performance & Regional sales demand
-- This is expected to reveal suppliers who are lagging and where the goods are going.

with shipments as (
    select * from {{ ref('stg_shipments') }}
),
stores as (
    select * from {{ ref('stg_stores') }}
),
suppliers as (
    select * from {{ ref('stg_suppliers') }}
),
products as (
    select * from {{ ref('stg_products') }}
)

select
    sh.shipment_id,
    sh.shipment_date,
    sh.expected_delivery_date,
    sh.actual_delivery_date,
    sh.delivery_delay_days,
    sup.supplier_name,
    sup.supplier_country,
    st.store_name,
    st.store_region,
    p.product_name,
    sh.quantity_shipped,
    sh.carrier,
    
    -- Logic: On-Time Delivery Flag (1 for Yes, 0 for No)
    case 
        when sh.actual_delivery_date <= sh.expected_delivery_date then 1 
        else 0 
    end as is_on_time,

    -- Logic: Late Delivery Flag
    case 
        when sh.actual_delivery_date > sh.expected_delivery_date then 1 
        else 0 
    end as is_late,

    -- Categorical Status for simple dashboard filtering
    case 
        when sh.actual_delivery_date <= sh.expected_delivery_date then 'On-Time'
        when sh.actual_delivery_date > sh.expected_delivery_date then 'Late'
        else 'Pending/Unknown'
    end as delivery_performance_status

from shipments sh
left join stores st on sh.store_id = st.store_id
left join products p on sh.product_id = p.product_id
left join suppliers sup on p.supplier_id = sup.supplier_id