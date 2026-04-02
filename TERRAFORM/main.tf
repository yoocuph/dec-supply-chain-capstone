# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "7.23.0"
#     }
#     local = {
#       source  = "hashicorp/local"
#       version = "~> 2.0"
#     }
#   }
# }

# provider "google" {
#   project = var.project_id
#   region  = var.region
# }


# # 1. Enable the APIs
# resource "google_project_service" "gcp_services" {
#   for_each = toset(var.gcp_service_list)
#   project  = var.project_id
#   service  = each.key
#   disable_on_destroy         = false 
#   disable_dependent_services = false 
# }

# # 1. Create the GCS Bucket (Infrastructure)
# resource "google_storage_bucket" "data_bucket" {
#   name                        = var.bucket_name
#   location                    = var.bucket_location
#   force_destroy               = true
#   uniform_bucket_level_access = true
#   versioning {
#     enabled = true
#   } # raw layer reproducibility
# }

# # 2. Create the Service Account
# resource "google_service_account" "migrator_sa" {
#   account_id   = var.sa_id
#   display_name = "Service Account for S3 to GCS Migration"
# }

# # 3. Grant the Service Account Admin permissions on the bucket
# resource "google_storage_bucket_iam_member" "admin_rule" {
#   bucket = google_storage_bucket.data_bucket.name
#   role   = "roles/storage.objectAdmin"
#   member = "serviceAccount:${google_service_account.migrator_sa.email}"
# }

# # 4. Generate the JSON key
# resource "google_service_account_key" "migrator_key" {
#   service_account_id = google_service_account.migrator_sa.name
# }

# # 5. Save the key to your local folder
# resource "local_file" "gcp_key" {
#   content  = base64decode(google_service_account_key.migrator_key.private_key)
#   filename = "${path.module}/gcp-key.json"
# }



# # 6. Enable bigquery API
# resource "google_project_service" "bigquery_api" {
#   service = "bigquery.googleapis.com"
#   disable_on_destroy = false
# }

# # 7. Create the BigQuery Dataset
# resource "google_bigquery_dataset" "raw_dataset" {
#   dataset_id                  = var.bq_dataset_id
#   friendly_name               = "Raw Ingestion Layer"
#   description                 = "This dataset contains external tables pointing to GCS"
#   location                    = var.bucket_location # Uses your existing location variable
#   delete_contents_on_destroy  = true
#   # Ensure APIs are on before creating dataset
#   depends_on = [google_project_service.gcp_services]
# }

# # 8. Create an External Table for S3 Data
# resource "google_bigquery_table" "s3_external_table" {
#   dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
#   table_id   = var.s3_table_id

#   external_data_configuration {
#     autodetect    = true
#     source_format = "PARQUET"
#     source_uris   = ["gs://${google_storage_bucket.data_bucket.name}/raw/*.parquet"]
#   }
# }

# # 9. Create an External Table for Store Info
# resource "google_bigquery_table" "stores_external_table" {
#   dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
#   table_id   = var.stores_table_id

#   external_data_configuration {
#     autodetect    = true
#     source_format = "PARQUET"
#     source_uris   = ["gs://${google_storage_bucket.data_bucket.name}/stores/*.parquet"]
#   }
# }


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.23.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  backend "gcs" {
    bucket  = "yussuf-alade-tf-state" 
    prefix  = "terraform/state"
  }
}


provider "google" {
  project = var.project_id
  region  = var.region
}

# --- 1. APIS & SERVICES ---
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = var.project_id
  service  = each.key
  
  disable_on_destroy         = false 
  disable_dependent_services = false 
}

# --- 2. IDENTITY & ACCESS (IAM) ---
resource "google_service_account" "migrator_sa" {
  account_id   = var.sa_id
  display_name = "Service Account for S3 and Sheets Migration"
}

# Generate the JSON key for scripts
resource "google_service_account_key" "migrator_key" {
  service_account_id = google_service_account.migrator_sa.name
}

# Save the key locally so Python can find it
resource "local_file" "gcp_key" {
  content  = base64decode(google_service_account_key.migrator_key.private_key)
  filename = "${path.module}/gcp-key.json"
}

# --- 3. STORAGE (GCS) ---
resource "google_storage_bucket" "data_bucket" {
  name                        = var.bucket_name
  location                    = var.bucket_location
  force_destroy               = true
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  } # raw layer reproducibility
}

# Grant SA permission to write to this specific bucket
resource "google_storage_bucket_iam_member" "admin_rule" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.migrator_sa.email}"
}

# --- 4. ANALYTICS (BIGQUERY) ---
resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id                  = var.bq_dataset_id
  friendly_name               = "Raw Ingestion Layer"
  description                 = "This dataset contains external tables pointing to GCS"
  location                    = var.bucket_location 
  delete_contents_on_destroy  = true

  # CRITICAL: Wait for APIs to be enabled before creating the dataset
  depends_on = [google_project_service.gcp_services]
}

# External Table: S3 Data
resource "google_bigquery_table" "s3_external_tables" {
  for_each = toset(var.s3_categories)

  dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
  table_id   = "stg_s3_${each.value}" #var.s3_table_id
  
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    source_uris   = ["gs://${google_storage_bucket.data_bucket.name}/raw/${each.value}/*.parquet"]
  }
}

# External Table: Store Information (from Google Sheets)
resource "google_bigquery_table" "stores_external_table" {
  dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
  table_id   = var.stores_table_id
  
  deletion_protection = false

  external_data_configuration {
    autodetect    = true
    source_format = "PARQUET"
    source_uris   = ["gs://${google_storage_bucket.data_bucket.name}/raw/stores/*.parquet"]
  }
}

# Granting the Service Account the necessary roles to run dbt
resource "google_project_iam_member" "dbt_roles" {
  for_each = toset([
    "roles/bigquery.jobUser",    # To run queries
    "roles/bigquery.dataEditor", # To create the new dev dataset/tables
    "roles/storage.objectViewer" # To read the Parquet files in GCS
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.migrator_sa.email}"
}

