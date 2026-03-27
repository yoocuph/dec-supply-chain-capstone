with source as (
    select * from {{ source('gcs_raw', 'stg_s3_warehouses') }}
)
select
    warehouse_id,
    city as warehouse_city,
    state as warehouse_state,
    -- _file_name as source_file
from source