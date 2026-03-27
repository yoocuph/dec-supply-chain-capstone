from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import os
import sys
sys.path.append('/opt/airflow')
from scripts.alerts import on_failure_callback

default_args = {
    'owner': 'yussuf',
    'start_date': datetime(2026, 3, 1), # Set to a past date to allow manual trigger
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'on_failure_callback': on_failure_callback,
}

with DAG(
    'supply_chain_full_pipeline',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False
) as dag:

    # 1. Extraction Task
    extract = BashOperator(
        task_id='extract_all_data',
        # We run the script from the /opt/airflow/scripts folder inside the container
        bash_command=(
            'python /opt/airflow/scripts/extract_postgres_sales.py && '
            'python /opt/airflow/scripts/extract_s3_data.py && '
            'python /opt/airflow/scripts/extract_storedata.py '
        ),
       env={
            **os.environ,
            "AWS_ACCESS_KEY_ID": os.getenv("AWS_ACCESS_KEY_ID"),
            "AWS_SECRET_ACCESS_KEY": os.getenv("AWS_SECRET_ACCESS_KEY"),
            "AWS_DEFAULT_REGION": "eu-west-1",
            "GOOGLE_APPLICATION_CREDENTIALS": "/opt/airflow/creds/gcp-key.json"
        }
    )


    # 2. dbt Run Task
    # Note: We use --profiles-dir . and assume the key is in /opt/airflow/creds/
    dbt_run = BashOperator(
        task_id='dbt_transformations',
        bash_command='cd /opt/airflow/supplychain_dbt && dbt run --profiles-dir .'
    )

    # 3. dbt Test Task
    dbt_test = BashOperator(
        task_id='dbt_data_quality_tests',
        bash_command='cd /opt/airflow/supplychain_dbt && dbt test --profiles-dir .'
    )

    extract >> dbt_run >> dbt_test