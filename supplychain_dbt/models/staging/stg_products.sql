with source as (
    select * from {{ source('gcs_raw', 'stg_s3_products') }}
)
select
    product_id,
    product_name,
    category,
    brand,
    supplier_id,
    cast(unit_price as float64) as unit_price,
    -- _file_name as source_file
from source