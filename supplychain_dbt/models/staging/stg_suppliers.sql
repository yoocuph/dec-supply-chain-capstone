with source as (
    select * from {{ source('gcs_raw', 'stg_s3_suppliers') }}
)
select
    supplier_id,
    supplier_name,
    category as supplier_category,
    country as supplier_country,
    -- _file_name as source_file
from source