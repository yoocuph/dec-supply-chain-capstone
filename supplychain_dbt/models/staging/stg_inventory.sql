{{
  config(
    materialized='incremental',
    unique_key='dbt_id'
  )
}}

with source as (
    select * from {{ source('gcs_raw', 'stg_s3_inventory') }}
),

renamed as (
    select
        concat(warehouse_id, '-', product_id, '-', cast(snapshot_date as string)) as dbt_id,
        warehouse_id,
        product_id,
        quantity_available,
        reorder_threshold,
     
        cast(snapshot_date as date) as snapshot_date,
        
        case 
            when quantity_available <= reorder_threshold then true 
            else false 
        end as is_low_stock,
        -- _file_name as source_file
    from source

    {% if is_incremental() %}
     
        where cast(snapshot_date as date) > (select max(snapshot_date) from {{ this }})
    {% endif %}
),

deduplicated as (
    select 
        *,
        row_number() over (
            partition by product_id, warehouse_id, snapshot_date 
            order by snapshot_date desc
        ) as row_num,
    from renamed
)

select 
    dbt_id,
    warehouse_id,
    product_id,
    quantity_available,
    reorder_threshold,
    snapshot_date,
    is_low_stock
from deduplicated 
where row_num = 1