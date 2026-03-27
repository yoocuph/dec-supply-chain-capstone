with source as (
    select * from {{ source('gcs_raw', 'stg_store_info_v2') }}
)
select
    store_id,
    store_name,
    city as store_city,
    state as store_state,
    region as store_region,
    cast(store_open_date as date) as store_open_date
from source