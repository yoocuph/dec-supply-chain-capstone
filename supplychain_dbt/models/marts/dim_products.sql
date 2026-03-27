select
    p.product_id,
    p.product_name,
    p.category as product_category,
    p.brand,
    p.unit_price,
    s.supplier_name,
    s.supplier_country
from {{ ref('stg_products') }} p
left join {{ ref('stg_suppliers') }} s on p.supplier_id = s.supplier_id