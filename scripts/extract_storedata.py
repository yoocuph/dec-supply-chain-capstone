import gspread
import pandas as pd
import io
from google.cloud import storage
from datetime import datetime

# CONFIG
SHEET_NAME = "launchPad-capstone-stores-table"
GCS_BUCKET = "supplychain360-gcs-data-yussuf-dec"
# GCP_KEY_PATH = 'TERRAFORM/gcp-key.json'
GCP_KEY_PATH = "/opt/airflow/creds/gcp-key.json"

def sync_sheets_to_gcs():
    # 1. Authorize gspread with my current key
    gc = gspread.service_account(filename=GCP_KEY_PATH)
    
    # print([s.title for s in gc.openall()]) # to check if my service account is communicating

    sh = gc.open(SHEET_NAME)
    worksheet = sh.get_worksheet(0) # First tab since there is just one tab
    
    # 2. Convert to DataFrame
    df = pd.DataFrame(worksheet.get_all_records())
    
    # 3. Convert to Parquet in-memory
    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, index=False)
    parquet_buffer.seek(0)
    
    # 4. Upload to GCS with the timestamp
    # ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    gcs_client = storage.Client.from_service_account_json(GCP_KEY_PATH)
    bucket = gcs_client.bucket(GCS_BUCKET)
    # blob = bucket.blob(f"raw/stores/stores_table_{ts}.parquet")
    blob = bucket.blob("raw/stores/stores_master.parquet")
    
    blob.upload_from_file(parquet_buffer, content_type='application/parquet')
    print(f"✅ Success: Google Sheet synced to GCS as Parquet")

if __name__ == "__main__":
    sync_sheets_to_gcs()