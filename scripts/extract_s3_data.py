import boto3
import pandas as pd
import io
import os
import re
from google.cloud import storage

# --- CONFIGURATION --- 
S3_BUCKET = 'supplychain360-data'
S3_PREFIX = 'raw/'
GCS_BUCKET = 'supplychain360-gcs-data-yussuf-dec'
GCP_KEY_PATH = "/opt/airflow/creds/gcp-key.json"

def get_idempotent_gcs_key(s3_key):
    """
    Determines the GCS path based on whether the data is static or daily.
    Prevents duplicates by avoiding execution timestamps.
    """
    # Clean the name (remove extension and prefix)
    clean_name = s3_key.replace('raw/', '').rsplit('.', 1)[0]
    
    # 1. Check for Daily Data (Inventory or Shipments)
    # This regex looks for dates like 2026-03-10 or 2026_03_10 in the filename
    date_match = re.search(r'(\d{4}[-_]\d{2}[-_]\d{2})', s3_key)
    
    if date_match:
        data_date = date_match.group(1).replace('-', '_')
        if 'inventory' in s3_key.lower():
            return f"raw/inventory/inventory_snapshot_{data_date}.parquet"
        if 'shipment' in s3_key.lower():
            return f"raw/shipments/shipment_log_{data_date}.parquet"
            
    # 2. Default for Static Data (Catalog, Suppliers, Warehouses)
    # We use a fixed name so it OVERWRITES instead of duplicating
    if 'product' in s3_key.lower():
        return "raw/products/products_catalog.parquet"
    if 'supplier' in s3_key.lower():
        return "raw/suppliers/suppliers_master.parquet"
    if 'warehouse' in s3_key.lower():
        return "raw/warehouses/warehouses_master.parquet"
        
    # Fallback: maintain folder structure but use a static name
    return f"raw/{clean_name}.parquet"

def migrate_and_convert():
    s3 = boto3.client('s3')
    gcs_client = storage.Client.from_service_account_json(GCP_KEY_PATH)
    gcs_bucket = gcs_client.bucket(GCS_BUCKET)

    paginator = s3.get_paginator('list_objects_v2')
    
    for page in paginator.paginate(Bucket=S3_BUCKET, Prefix=S3_PREFIX):
        for obj in page.get('Contents', []):
            s3_key = obj['Key']
            if s3_key.endswith('/'): continue

            # Determine the NEW idempotent GCS path
            gcs_key = get_idempotent_gcs_key(s3_key)
            print(f"Processing: {s3_key} -> Target GCS: {gcs_key}")
            
            resp = s3.get_object(Bucket=S3_BUCKET, Key=s3_key)
            data = resp['Body'].read()
            
            try:
                if s3_key.endswith('.csv'):
                    df = pd.read_csv(io.BytesIO(data))
                elif s3_key.endswith('.json'):
                    df = pd.read_json(io.BytesIO(data))
                else:
                    continue

                parquet_buffer = io.BytesIO()
                df.to_parquet(parquet_buffer, index=False, engine='pyarrow')
                parquet_buffer.seek(0)

                blob = gcs_bucket.blob(gcs_key)
                
                # We removed the dynamic 'ts' variable here.
                # Every upload now OVERWRITES the file at gcs_key.
                blob.upload_from_file(parquet_buffer, content_type='application/parquet')
                
                print(f"✅ Success: {s3_key} uploaded to {gcs_key}")

            except Exception as e:
                print(f"❌ Failed to convert {s3_key}: {e}")

if __name__ == "__main__":
    migrate_and_convert()


# import boto3
# import pandas as pd
# import io
# from google.cloud import storage
# from datetime import datetime # this is needed to add timestamp

# # --- CONFIGURATION --- 
# S3_BUCKET = 'supplychain360-data'
# S3_PREFIX = 'raw/'
# GCS_BUCKET = 'supplychain360-gcs-data-yussuf-dec'
# # GCP_KEY_PATH = 'TERRAFORM/gcp-key.json'
# GCP_KEY_PATH = "/opt/airflow/creds/gcp-key.json"


# def migrate_and_convert():
#     s3 = boto3.client('s3')
#     gcs_client = storage.Client.from_service_account_json(GCP_KEY_PATH)
#     gcs_bucket = gcs_client.bucket(GCS_BUCKET)

#     paginator = s3.get_paginator('list_objects_v2')
    
#     for page in paginator.paginate(Bucket=S3_BUCKET, Prefix=S3_PREFIX):
#         for obj in page.get('Contents', []):
#             s3_key = obj['Key']
#             if s3_key.endswith('/'): continue

#             print(f"Processing: {s3_key}...")
            
#             # 1. Download S3 object to memory
#             resp = s3.get_object(Bucket=S3_BUCKET, Key=s3_key)
#             data = resp['Body'].read()
            
#             # 2. Load into Pandas based on file type
#             try:
#                 if s3_key.endswith('.csv'):
#                     df = pd.read_csv(io.BytesIO(data))
#                 elif s3_key.endswith('.json'):
#                     df = pd.read_json(io.BytesIO(data))
#                 else:
#                     print(f"Skipping {s3_key}: Not a supported format.")
#                     continue

#                 # 3. Convert to Parquet in memory
#                 parquet_buffer = io.BytesIO()
#                 df.to_parquet(parquet_buffer, index=False, engine='pyarrow')
#                 parquet_buffer.seek(0)

#                 # Start update: Metadata & Reproducibility

#                 ts = datetime.now().strftime("%Y%m%d_%H%M%S")

#                 # 4. Upload to GCS with timestamp in name to prevent overwriting

#                 # To change the 'raw/file.parquet' to 'raw/20260317_183005_file.parquet'
#                 base_name = s3_key.rsplit('.', 1)[0]
#                 gcs_key = f"{base_name}_{ts}.parquet"
                
#                 blob = gcs_bucket.blob(gcs_key)
                
#                 # Attach metadata for internal tracking
#                 blob.metadata = {
#                     "ingestion_timestamp": ts,
#                     "original_s3_key": s3_key
#                 }
                
#                 blob.upload_from_file(parquet_buffer, content_type='application/parquet')

#                 # 4. Upload to GCS with new extension
#                 # gcs_key = s3_key.rsplit('.', 1)[0] + '.parquet'
#                 # blob = gcs_bucket.blob(gcs_key)
#                 # blob.upload_from_file(parquet_buffer, content_type='application/octet-stream')

#                 # End update: Metadata & Reproducibility
                
#                 print(f"✅ Success: {s3_key} -> {gcs_key}")

#             except Exception as e:
#                 print(f"❌ Failed to convert {s3_key}: {e}")

# if __name__ == "__main__":
#     migrate_and_convert()