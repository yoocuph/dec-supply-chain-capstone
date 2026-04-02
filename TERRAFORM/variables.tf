variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "bucket_location" {
  description = "The GCS bucket location (Multi-region or Region)"
  type        = string
  default     = "EU"
}

variable "bucket_name" {
  description = "The globally unique name for the GCS bucket"
  type        = string
}

variable "sa_id" {
  description = "The ID for the service account"
  type        = string
  default     = "s3-to-gcs-migrator"
}





variable "bq_dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
  default     = "supplychain_raw"
}

variable "s3_table_id" {
  type    = string
  default = "stg_s3_data"
}

variable "s3_categories" {
  description = "List of folders in the raw directory"
  type        = list(string)
  default     = ["inventory", "products", "shipments", "suppliers", "warehouses", "sales"]
}

variable "stores_table_id" {
  type    = string
  default = "stg_store_info"
}

variable "gcp_service_list" {
  description = "The list of APIs necessary for the project"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com", # Essential for Terraform project management
    "iam.googleapis.com",                  # Required to manage Service Accounts/Keys
    "storage.googleapis.com",              # Required for your GCS Buckets
    "drive.googleapis.com",                # Required for gspread to find files
    "sheets.googleapis.com",               # Required for gspread to read data
    "bigquery.googleapis.com"              # Required for your BQ tables
  ]
}