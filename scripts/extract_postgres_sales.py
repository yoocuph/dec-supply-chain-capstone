import psycopg2
from sqlalchemy import create_engine
import pandas as pd
from google.cloud import storage
import io
import os

DB_CONFIG = {
    "host": "aws-1-eu-west-1.pooler.supabase.com",
    "database": "postgres", 
    "user": "postgres.jzwdfotpgikjhmmyojok",
    "password": "decommitorbounce",
    "port": "6543"
}

# Create the SQLAlchemy Connection 
DB_URI = f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"

BUCKET_NAME = "supplychain360-gcs-data-yussuf-dec"
# GCP_KEY_PATH = "TERRAFORM/gcp-key.json"
GCP_KEY_PATH = "/opt/airflow/creds/gcp-key.json"
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = GCP_KEY_PATH

# The specific tables mentioned in your project
sales_tables = [
    "sales_2026_03_10", "sales_2026_03_11", "sales_2026_03_12",
    "sales_2026_03_13", "sales_2026_03_14", "sales_2026_03_15", "sales_2026_03_16"
]

def extract_and_upload():
    storage_client = storage.Client()
    bucket = storage_client.bucket(BUCKET_NAME)
    
    try:
        # 1. Connect to Postgres
        conn = psycopg2.connect(**DB_CONFIG)
        print("Connected to Postgres successfully.")

        for table in sales_tables:
            print(f"Fetching data from {table}...")
            
            # 2. Extract to Pandas (One query per table to be gentle on the DB)
            query = f"SELECT * FROM public.\"{table}\"" # Using quotes in case of case-sensitivity
            df = pd.read_sql(query, conn)
            
            if df.empty:
                print(f"Warning: {table} is empty. Skipping.")
                continue

            # 3. Convert to Parquet in memory
            parquet_buffer = io.BytesIO()
            df.to_parquet(parquet_buffer, index=False)
            
            # 4. Upload to GCS (Folder: raw/sales/)
            gcs_path = f"raw/sales/{table}.parquet"
            blob = bucket.blob(gcs_path)
            blob.upload_from_string(parquet_buffer.getvalue(), content_type='application/octet-stream')
            
            print(f"Successfully uploaded {table} to gs://{BUCKET_NAME}/{gcs_path}")

        conn.close()
        print("All sales tables processed.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    extract_and_upload()