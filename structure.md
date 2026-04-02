supplychain360-data-platform/

├── README.md
├── .gitignore
├── requirements.txt
├── pyproject.toml

├── docs/
│   ├── architecture_diagram.png
│   ├── models_diagram.png
│   └── presentation/
│       └── supplychain360_platform.pptx

├── airflow/
│   ├── dags/
│       └── supply_chain_orchestration.py
│   
│
├── scripts/
│   ├── extract_s3_data.py
│   ├── extract_postgres_sales.py
│   ├── extract_storedata.py
│   └── alerts.py
│ 
│ 
│              
│       

├── processing/
│   ├── clean_inventory.py
│   ├── clean_shipments.py
│   ├── clean_sales.py
│   │
│   └── validation/
│       ├── schema_checks.py
│       └── foreign_key_checks.py

├── storage/
│   ├── parquet_writer.py
│   └── metadata_manager.py

├── dbt/
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_suppliers.sql
│   │   │   ├── stg_inventory.sql
│   │   │   └── stg_sales.sql
│   │   │
│   │   ├── marts/
│   │   │   ├── dim_products.sql
│   │   │   ├── dim_suppliers.sql
│   │   │   ├── dim_warehouses.sql
│   │   │   ├── dim_stores.sql
│   │   │   ├── fact_sales.sql
│   │   │   ├── fact_inventory.sql
│   │   │   └── fact_shipments.sql
│   │
│   └── tests/
│       ├── unique_keys.yml
│       └── relationships.yml

├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   │
│   ├── modules/
│   │   ├── s3_bucket/
│   │   ├── data_warehouse/
│   │   └── airflow_environment/

├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml

├── scripts/
│   ├── run_pipeline.sh
│   └── setup_environment.sh

├── tests/
│   ├── test_ingestion.py
│   ├── test_processing.py
│   └── test_transformations.py

└── .github/
└── workflows/
└── ci_cd_pipeline.yml
