from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from google.cloud import bigquery

# ──────────────────────────────────────────────
# CONFIG — update these before deploying
# ──────────────────────────────────────────────
BUCKET_URI = "gs://sales_bucket_demo_007/data.csv"   # your GCS bucket path
BQ_TABLE   = "YOUR_PROJECT_ID.demo_dataset.sales_data"  # your project ID
# ──────────────────────────────────────────────


def load_to_bq():
    """
    Extract: reads data.csv from GCS bucket.
    Transform: minimal — skips no header rows, raw CSV as-is.
    Load: inserts rows into BigQuery sales_data table.
    """
    client = bigquery.Client()

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=0,   # no header row in our CSV
        autodetect=False,
        schema=[
            bigquery.SchemaField("id",     "INT64"),
            bigquery.SchemaField("name",   "STRING"),
            bigquery.SchemaField("amount", "FLOAT"),
        ],
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,  # overwrite on each run
    )

    load_job = client.load_table_from_uri(
        BUCKET_URI,
        BQ_TABLE,
        job_config=job_config,
    )

    load_job.result()  # wait for job to complete
    print(f"✅ Loaded data from {BUCKET_URI} → {BQ_TABLE}")


# ── DAG definition ────────────────────────────
with DAG(
    dag_id="batch_etl_demo",
    description="Daily ETL: GCS CSV → BigQuery sales_data",
    start_date=datetime(2026, 4, 10),   # update to today's date (y, m, d)
    schedule_interval="@daily",
    catchup=False,
    tags=["gcp", "etl", "bigquery"],
) as dag:

    load_task = PythonOperator(
        task_id="load_to_bq",
        python_callable=load_to_bq,
    )
