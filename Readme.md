# SupplyChain360 Unified Data Platform

**Unified Supply Chain Data Platform for Supplychain 360**  

---

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

### Business Objectives

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

# Project Structure

```
supplychain360-data-platform/
│
├── dags/
│   └── airflow pipelines
|        └── supply_chain_orchestration.py
│
├── ingestion/
│   └── data extraction scripts
│        └── extract_postgres_sales.py
|        └── extract_product.py
|        └── extract_storedata.py
|
├── transformations/
│   └── supplychain_dbt models
|        └── models
|              └── staging
|               └── intermediate
|               └── marts
│
├── infrastructure/
│   └── terraform configuration
|           └── GCS
|           └── Google BigQuery
│
├── docker/
│   └── docker configuration
│
├── docs/
│   └── architecure diagram.png
|   └── presentation.ppt
│
└── README.md
```

---

# Architecture Overview

![architectural diagram](<docs/Pasted image.png>)

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

# Choice of tools and Technology Stack

The platform uses the following modern data engineering tools:

| Tool                            | Purpose                           |
| ------------------------------- | --------------------------------- |
| Python                          | Data ingestion and processing     |
| Apache Airflow                  | Workflow orchestration            |
| GCS                             | Raw data storage                  |
| BigQuery                        | Data warehouse                    |
| dbt                             | Data modeling and transformations |
| Docker                          | Containerization                  |
| Terraform                       | Infrastructure as Code            |
| GitHub Actions                  | CI/CD pipeline                    |

---


# System Architecture

The platform follows a modern **data lakehouse architecture** consisting of several layers:

1. **Data Ingestion Layer**

   * Extracts data from operational systems
   * Converts data into Parquet format
   * Stores raw immutable data in cloud object storage (GCS)

2. **Raw Data Layer**

   * Stores source data exactly as received in GCS
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

# Data Warehouse Design

The analytical data model follows a **Star Schema** design.

![model diagram](<docs/models_diagram.png>)

### Dimension Tables

* `dim_products`
* `dim_locations`

### Fact Tables

* `fct_supply_chain_health`

This structure enables efficient analysis of:

* product demand trends
* supplier delivery performance
* warehouse efficiency
* regional sales patterns

---

# Workflow Orchestration

The entire data pipeline is orchestrated using **Apache Airflow**.

Airflow coordinates:

1. Data extraction from all sources programatically
2. Loading raw datasets to object storage (GCS)
3. Data warehouse loading
4. Data cleaning and validation (dbt)
5. dbt model execution (dbt)
6. Data quality checks (dbt)

The pipelines are designed with production best practices including:

* idempotent tasks
* incremental data processing
* retry mechanisms
* failure alerting (airflow)

---

# Infrastructure

All cloud infrastructure is provisioned using **Terraform**.

Provisioned cloud resources include:

* Object storage buckets (Google Cloud Storage)
* Data warehouse infrastructure (Google BigQuery)

Terraform state is stored in a remote backend to support collaborative infrastructure management.

---

# Containerization

All application components are packaged in a **Docker image** to ensure reproducibility across environments.

The Docker image includes:

* Python ingestion scripts
* Airflow DAGs
* dbt project
* required dependencies

The image is pushed to a container registry for deployment (ducker hub).

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

# Future Improvements

Potential extensions of the platform include:

* Demand forecasting models
* Inventory optimization algorithms
* Supplier reliability scoring
* Real-time shipment monitoring

---

# How to Run the Project

## Instructions for running the project locally and deploying infrastructure: Quick Start Guide: Running the Pipeline.

This project is fully containerized. Follow these steps to deploy the environment using the pre-built Docker image

1. Prerequisites
   
   * **Docker & Docker Compose** installed.

   * **Google Cloud** Platform project with a Service Account key (gcp-key.json).

   * **AWS** Credentials (Access Key & Secret Key) for S3 access.

2. Clone the Repository

```bash
git clone https://github.com/yoocuph/supply-chain-capstone.git
cd supply-chain-capstone
```

3. Environment Setup

Create a `.env` file in the root directory and add your credentials. This file is ignored by Git for security.

```
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=eu-west-1
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

Place your Google Cloud Service Account key in a folder named `creds/` and rename it to `gcp-key.json`.

4. Launch the Stack
Run the following command. Docker will automatically pull the image `yoocuph/supply-chain-capstone:latest` from Docker Hub.

```
docker-compose up -d
```

5. Access the Pipeline

   * Airflow UI: Open `http://localhost:8081`

   * Credentials: Username: `airflow` | Password: `airflow`

   * Trigger: Unpause the `supply_chain_full_pipeline` DAG and click the Play button.

## Infrastructure Setup (Optional)
If you are setting this up in a new GCP project, use the included Terraform files to provision the required BigQuery datasets and GCS buckets:

```bash
cd TERRAFORM
terraform init
terraform apply
```

---


# Author

Yussuf Alade - Supply Chain Data Engineer
