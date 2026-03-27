select
    store_id as location_id,
    store_name as location_name,
    store_city as city,
    store_region as region,
    'STORE' as location_type
from {{ ref('stg_stores') }}

union all

select
    warehouse_id as location_id,
    'Warehouse ' || warehouse_id as location_name,
    warehouse_city as city,
    'WAREHOUSE' as region, -- Or map this to a region if you have one
    'WAREHOUSE' as location_type
from {{ ref('stg_warehouses') }}