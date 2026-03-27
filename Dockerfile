
FROM apache/airflow:2.7.1-python3.9

USER root

# To install system dependencies if needed
RUN apt-get update && apt-get install -y git && apt-get clean

USER airflow

# COPY requirements.txt /requirements.txt
RUN pip install \
    "dbt-bigquery==1.7.0" \
    "pyarrow" \
    "fastparquet" \
    "apache-airflow-providers-google" \
    "gspread" \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.1/constraints-3.9.txt"

COPY --chown=airflow:root dags/ /opt/airflow/dags/
COPY --chown=airflow:root scripts/ /opt/airflow/scripts/
COPY --chown=airflow:root supplychain_dbt/ /opt/airflow/supplychain_dbt/
COPY --chown=airflow:root creds/ /opt/airflow/creds/

WORKDIR /opt/airflow