{{
  config(
    materialized='incremental',
    unique_key='shipment_id'
  )
}}

with source as (
    select * from {{ source('gcs_raw', 'stg_s3_shipments') }}
),

transformed as (
    select
        shipment_id,
        warehouse_id,
        store_id,
        product_id,
        quantity_shipped,

        -- Standardizing dates for downstream consistency

        
        -- cast(shipment_date as date) as shipment_date,
        -- cast(expected_delivery_date as date) as expected_delivery_date,
        -- cast(actual_delivery_date as date) as actual_delivery_date,

        extract(date from safe.timestamp(cast(shipment_date as string))) as shipment_date,
        extract(date from safe.timestamp(cast(expected_delivery_date as string))) as expected_delivery_date,
        extract(date from safe.timestamp(cast(actual_delivery_date as string))) as actual_delivery_date,

        carrier,
        -- Logic: Positive number means late, negative means early
        -- date_diff(cast(actual_delivery_date as date), cast(expected_delivery_date as date), day) as delivery_delay_days,
        -- _file_name as source_file
        date_diff(
            extract(date from safe.timestamp(cast(actual_delivery_date as string))), 
            extract(date from safe.timestamp(cast(expected_delivery_date as string))), 
            day
        ) as delivery_delay_days
    from source
)

select * from transformed

{% if is_incremental() %}
    where shipment_date > (select max(shipment_date) from {{ this }})
{% endif %}