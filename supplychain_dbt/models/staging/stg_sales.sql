{{
  config(
    materialized='incremental',
    unique_key='transaction_id'
  )
}}

with source as (
    select * from {{ source('gcs_raw', 'stg_s3_sales') }}
),

transformed as (
select
    transaction_id,
    store_id,
    product_id,
    cast(quantity_sold as int64) as quantity_sold,
    cast(unit_price as float64) as unit_price,
    cast(discount_pct as float64) as discount_pct,
    cast(sale_amount as float64) as sale_amount,
    cast(transaction_timestamp as date) as transaction_date,
    -- date(timestamp_seconds(cast(transaction_timestamp as int64))) as transaction_date
    -- date(timestamp_micros(cast(transaction_timestamp / 1000 as int64))) as transaction_date
    -- _file_name as source_file
from source
)

select * from transformed

{% if is_incremental() %}
  where transaction_date > (select max(transaction_date) from {{ this }})
{% endif %}