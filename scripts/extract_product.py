# import boto3

# # Create an S3 client
# s3_client = boto3.client('s3', aws_access_key_id='YOUR_ACCESS_KEY', aws_secret_access_key='YOUR_SECRET_KEY')

# # Read an object from the bucket
# response = s3_client.get_object(Bucket='your-bucket-name', Key='your-object-key')

# # Read the object’s content as text
# object_content = response['Body'].read().decode('utf-8')

# # Process or use the content as needed
# print(object_content)

# upload a file
# s3 = boto3.client('s3')
# s3.download_file('supplychain360-data', 'raw/products/', '/home/yussuf-alade/yoocu/capstone_project/products.csv')

# import boto3
# import os
# from pathlib import Path

# bucket_name = 'supplychain360-data'
# prefix = 'raw/products/' 

# def download_s3_bucket(bucket_name, local_path):
#     s3 = boto3.client('s3')
#     paginator = s3.get_paginator('list_objects_v2')

#     # Iterate through all pages of objects in the bucket
#     for page in paginator.paginate(Bucket=bucket_name):
#         if 'Contents' in page:
#             for obj in page['Contents']:
#                 s3_key = obj['Key']
                
#                 # Define the local file path
#                 local_file_path = Path(local_path) / s3_key
                
#                 # Create local subdirectories if they don't exist
#                 local_file_path.parent.mkdir(parents=True, exist_ok=True)
                
#                 # Download the file (skip if the key is just a "folder" prefix)
#                 if not s3_key.endswith('/'):
#                     print(f"Downloading: {s3_key}")
#                     s3.download_file(bucket_name, s3_key, str(local_file_path))

# Usage
# download_s3_bucket('supplychain360-data', '/home/yussuf-alade/yoocu/capstone_project/')

# import boto3
# from botocore.exceptions import ClientError

# def check_aws_permissions(bucket_name, object_key):
#     # Initialize clients
#     sts = boto3.client('sts')
#     s3 = boto3.client('s3')

#     try:
#         # 1. Who am I?
#         identity = sts.get_caller_identity()
#         print(f"--- Identity Found ---")
#         print(f"Account: {identity['Account']}")
#         print(f"ARN:     {identity['Arn']}")
#         print(f"User ID: {identity['UserId']}\n")

#         # 2. Can I see the bucket?
#         print(f"--- Testing Access to {bucket_name} ---")
#         s3.head_bucket(Bucket=bucket_name)
#         print(f"SUCCESS: Can access bucket metadata.")

#         # 3. Can I read the specific file?
#         s3.head_object(Bucket=bucket_name, Key=object_key)
#         print(f"SUCCESS: Can read object '{object_key}'.")

#     except ClientError as e:
#         error_code = e.response['Error']['Code']
#         print(f"FAILURE: {error_code}")
#         if error_code == '403':
#             print("Action: Check your IAM Policy. You likely need 's3:GetObject'.")
#         elif error_code == '404':
#             print("Action: The file path (Key) is incorrect. Check for typos/slashes.")
#         else:
#             print(f"Error Details: {e}")

# # REPLACE with your actual bucket and a specific FILE key (not a folder)
# check_aws_permissions('supplychain360-data', 'raw/products/.csv')


# import boto3

# s3 = boto3.client('s3')
# bucket_name = 'supplychain360-data'
# prefix = 'raw/products/' # The "folder" you're looking in

# response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

# if 'Contents' in response:
#     print(f"Files found in {prefix}:")
#     for obj in response['Contents']:
#         print(f" - {obj['Key']}")
# else:
#     print(f"No files found starting with {prefix}. Check your spelling!")

# getting everthing inside raw

# import boto3
# import os

# def download_s3_folder(bucket_name, s3_prefix, local_dir):
#     s3 = boto3.client('s3')
    
#     # 1. Setup the paginator to "scroll" through all objects
#     paginator = s3.get_paginator('list_objects_v2')
    
#     # 2. Start iterating through the bucket
#     for page in paginator.paginate(Bucket=bucket_name, Prefix=s3_prefix):
#         if 'Contents' not in page:
#             print(f"No files found in {s3_prefix}")
#             return

#         for obj in page['Contents']:
#             s3_key = obj['Key']
            
#             # Skip keys that are just "folders" (ending in /)
#             if s3_key.endswith('/'):
#                 continue
            
#             # 3. Determine the local file path
#             # This keeps the folder structure (e.g., raw/products/products.csv)
#             local_file_path = os.path.join(local_dir, s3_key)
            
#             # Create local directories if they don't exist
#             local_file_dir = os.path.dirname(local_file_path)
#             if not os.path.exists(local_file_dir):
#                 os.makedirs(local_file_dir)
            
#             # 4. Download the file
#             print(f"Downloading: {s3_key}")
#             s3.download_file(bucket_name, s3_key, local_file_path)

# # --- EXECUTION ---
# BUCKET = 'supplychain360-data'
# S3_FOLDER = 'raw/'           # Everything inside 'raw'
# LOCAL_TARGET = './downloads' # Where to save it on your PC

# download_s3_folder(BUCKET, S3_FOLDER, LOCAL_TARGET)
# print("--- All downloads complete ---")

# Name:/supplychain360/db/dbname 
# arn:aws:ssm:eu-west-2:199816166528:parameter/supplychain360/db/dbname
# value: postgres

# Name:/supplychain360/db/host
# arn:aws:ssm:eu-west-2:199816166528:parameter/supplychain360/db/host
# value: aws-1-eu-west-1.pooler.supabase.com

# Name:/supplychain360/db/password
# arn:aws:ssm:eu-west-2:199816166528:parameter/supplychain360/db/password
# value: decommitorbounce


# Name:/supplychain360/db/port
# arn:aws:ssm:eu-west-2:199816166528:parameter/supplychain360/db/port
# value: 6543

# Name:/supplychain360/db/user
# arn:aws:ssm:eu-west-2:199816166528:parameter/supplychain360/db/user
# value: postgres.jzwdfotpgikjhmmyojok