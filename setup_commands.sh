#!/bin/bash
# =============================================================
# GCP End-to-End Data Pipeline — Setup Script
# Run each section in Google Cloud Shell
# =============================================================

# ── 0. Set your project ID ────────────────────────────────────
export PROJECT_ID="YOUR_PROJECT_ID"   # ← replace this
gcloud config set project $PROJECT_ID


# ── 1. Enable required GCP services ──────────────────────────
gcloud services enable composer.googleapis.com    # Airflow (ETL orchestration)
gcloud services enable pubsub.googleapis.com      # Pub/Sub (streaming)
gcloud services enable bigquery.googleapis.com    # BigQuery (data warehouse)


# ── 2. Create BigQuery dataset & table ───────────────────────
bq mk demo_dataset

bq mk --table demo_dataset.sales_data \
    id:INT64,name:STRING,amount:FLOAT


# ── 3. Create GCS bucket & upload data ───────────────────────
gcloud storage buckets create gs://sales_bucket_demo_007

# Create sample CSV (or upload your own data/data.csv)
cat > data.csv << 'EOF'
101,Casselyn,5000
102,Zhining,3000
103,Andika,7000
104,MikiTong,9000
105,Jacub,4500
EOF

# Verify file
cat data.csv

# Copy to bucket
gcloud storage cp data.csv gs://sales_bucket_demo_007

# Verify upload
gcloud storage ls gs://sales_bucket_demo_007


# ── 4. Install Python dependencies ───────────────────────────
pip3 install google-cloud-bigquery
pip3 install google-cloud-pubsub


# ── 5. Create Cloud Composer (Airflow) environment ───────────
# NOTE: This takes ~20 minutes to provision
gcloud composer environments create sampledemoairflowapp \
    --location us-central1 \
    --image-version composer-3-airflow-2.9.3-build.53


# ── 6. Deploy DAG to Composer ─────────────────────────────────
gcloud composer environments storage dags import \
    --environment sampledemoairflowapp \
    --location us-central1 \
    --source dags/etl_dag.py


# ── 7. Query results in BigQuery ─────────────────────────────
bq query "SELECT * FROM demo_dataset.sales_data"

# Aggregate query example
bq query "SELECT name, amount FROM demo_dataset.sales_data ORDER BY amount DESC"
