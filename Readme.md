# SupplyChain360 Unified Data Platform

## Project Overview

SupplyChain360 is a fast-growing retail distribution company in the United States that manages product distribution for hundreds of retail stores nationwide.

Over the past year, the company has experienced major supply chain inefficiencies including:

* Frequent stockouts of popular products
* Overstocked warehouses for slow-moving items
* Shipment delivery delays
* Lack of visibility into supplier performance and inventory movement

Operational data is currently fragmented across multiple systems including warehouse management tools, logistics systems, supplier records, and store sales databases. Each team manages its own data and reports are manually compiled weekly, leading to outdated insights.

To address these challenges, this project implements a **Unified Supply Chain Data Platform** that centralizes operational data and enables efficient analytics for inventory optimization, supplier monitoring, and demand forecasting.

The platform ingests raw data from multiple sources, processes and models the data into a structured data warehouse, and enables analytical queries to support better decision-making.

---

# Business Objectives

The platform is designed to help SupplyChain360 answer critical operational questions such as:

* Which products cause the most stockouts?
* Which warehouses operate inefficiently?
* Which suppliers consistently deliver late?
* Which regions experience the highest product demand?

By enabling these insights, the platform can support:

* Better inventory planning
* Supplier performance monitoring
* Shipment tracking improvements
* Demand forecasting across regions

---

# Data Sources

The platform integrates multiple operational datasets from different systems:

| Dataset                       | Source        | Format          | Frequency |
| ----------------------------- | ------------- | --------------- | --------- |
| Product Catalog               | AWS S3        | CSV             | Static    |
| Store Locations               | Google Sheets | Spreadsheet     | Static    |
| Suppliers Data                | AWS S3        | CSV             | Static    |
| Warehouses                    | AWS S3        | CSV             | Static    |
| Warehouse Inventory Snapshots | AWS S3        | CSV             | Daily     |
| Shipment Delivery Logs        | AWS S3        | JSON            | Daily     |
| Store Sales Transactions      | PostgreSQL    | Database Tables | Daily     |

Sales tables are generated daily in the transactional PostgreSQL database under the `store_sales` schema.

---

# System Architecture

The platform follows a modern **data lakehouse architecture** consisting of several layers:

1. **Data Ingestion Layer**

   * Extracts data from operational systems
   * Converts data into Parquet format
   * Stores raw immutable data in cloud object storage

2. **Raw Data Layer**

   * Stores source data exactly as received
   * Includes ingestion metadata
   * Enables reproducibility and auditing

3. **Data Processing Layer**

   * Cleans and standardizes datasets
   * Resolves schema inconsistencies
   * Validates relationships across datasets

4. **Data Warehouse Layer**

   * Models data using fact and dimension tables
   * Enables efficient analytical queries

5. **Analytics Layer**

   * Supports operational insights for supply chain optimization

---

# Technology Stack

The platform uses the following modern data engineering tools:

| Tool                            | Purpose                           |
| ------------------------------- | --------------------------------- |
| Python                          | Data ingestion and processing     |
| Apache Airflow                  | Workflow orchestration            |
| AWS S3                          | Raw data storage                  |
| Parquet                         | Columnar storage format           |
| PostgreSQL                      | Source transactional data         |
| dbt                             | Data modeling and transformations |
| Snowflake / BigQuery / Redshift | Data warehouse                    |
| Docker                          | Containerization                  |
| Terraform                       | Infrastructure as Code            |
| GitHub Actions                  | CI/CD pipeline                    |

---

# Data Warehouse Design

The analytical data model follows a **Star Schema** design.

### Dimension Tables

* `dim_products`
* `dim_suppliers`
* `dim_warehouses`
* `dim_stores`
* `dim_date`

### Fact Tables

* `fact_sales`
* `fact_inventory`
* `fact_shipments`

This structure enables efficient analysis of:

* product demand trends
* supplier delivery performance
* warehouse efficiency
* regional sales patterns

---

# Workflow Orchestration

The entire data pipeline is orchestrated using **Apache Airflow**.

Airflow coordinates:

1. Data extraction from all sources
2. Loading raw datasets to object storage
3. Data cleaning and validation
4. Data warehouse loading
5. dbt model execution
6. Data quality checks

The pipelines are designed with production best practices including:

* idempotent tasks
* incremental data processing
* retry mechanisms
* failure alerting

---

# Infrastructure

All cloud infrastructure is provisioned using **Terraform**.

Provisioned resources include:

* Object storage buckets
* Data warehouse infrastructure
* Airflow execution environment
* IAM roles and permissions
* Parameter store for secure credentials

Terraform state is stored in a remote backend to support collaborative infrastructure management.

---

# Containerization

All application components are packaged in a **Docker image** to ensure reproducibility across environments.

The Docker image includes:

* Python ingestion scripts
* Airflow DAGs
* dbt project
* required dependencies

The image is pushed to a container registry for deployment.

---

# CI/CD Pipeline

A CI/CD pipeline is implemented using **GitHub Actions**.

### Continuous Integration

* Code linting
* Formatting checks
* Automated tests

### Continuous Deployment

* Build Docker image
* Push image to container registry
* Deploy updated pipelines

---

# Project Structure

```
supplychain360-data-platform/
│
├── dags/
│   └── airflow pipelines
│
├── ingestion/
│   └── data extraction scripts
│
├── transformations/
│   └── dbt models
│
├── infrastructure/
│   └── terraform configuration
│
├── docker/
│   └── docker configuration
│
├── tests/
│   └── pipeline tests
│
└── README.md
```

---

# Future Improvements

Potential extensions of the platform include:

* Demand forecasting models
* Inventory optimization algorithms
* Supplier reliability scoring
* Real-time shipment monitoring

---

# How to Run the Project

Instructions for running the project locally and deploying infrastructure will be added as the implementation progresses.

---

# Author

Yussuf Alade - Supply Chain Data Engineer
