# 🚀 End-to-End Data Pipeline on GCP

A hands-on implementation of a cloud-native data pipeline using **Google Cloud Platform**, covering batch ETL orchestration, data warehousing, and streaming infrastructure.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   Raw Data (CSV)                                        │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐     ┌─────────────────┐               │
│  │ Cloud       │────▶│  Cloud Composer │               │
│  │ Storage     │     │  (Airflow DAG)  │               │
│  │ (GCS Bucket)│     │  batch_etl_demo │               │
│  └─────────────┘     └────────┬────────┘               │
│                               │                        │
│                               ▼                        │
│                      ┌─────────────────┐               │
│                      │   BigQuery      │               │
│                      │  demo_dataset   │               │
│                      │  .sales_data    │               │
│                      └─────────────────┘               │
│                                                         │
│  ┌─────────────┐                                        │
│  │  Pub/Sub    │  ◀── Streaming layer (event-driven)   │
│  └─────────────┘                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Service | GCP Product | Role |
|---|---|---|
| Orchestration | Cloud Composer (Airflow) | Schedules & runs ETL pipeline daily |
| Storage | Cloud Storage (GCS) | Stores raw CSV data files |
| Data Warehouse | BigQuery | Stores & queries final processed data |
| Streaming | Pub/Sub | Event-driven / streaming data layer |
| CLI | Cloud Shell + gcloud | Infrastructure setup & deployment |

---

## 📁 Project Structure

```
gcp-end-to-end-data-pipeline/
│
├── dags/
│   └── etl_dag.py          # Airflow DAG — GCS → BigQuery ETL
│
├── data/
│   └── data.csv            # Sample sales dataset
│
├── setup/
│   └── setup_commands.sh   # All gcloud / bq setup commands
│
└── README.md
```

---

## ⚙️ Pipeline Flow

1. **Raw data** (`data.csv`) is uploaded to a **GCS bucket**
2. **Airflow DAG** (`batch_etl_demo`) triggers on a `@daily` schedule
3. The `load_to_bq` Python task reads the CSV from GCS
4. Data is loaded into the **BigQuery** table `demo_dataset.sales_data`
5. Analytics queries can be run directly on BigQuery

---

## 🚀 Setup & Deployment

### Prerequisites
- A GCP account (free trial works — ₹28,000 / $300 credits)
- Google Cloud Shell (browser-based, no local setup needed)

### Step 1 — Enable GCP Services
```bash
gcloud services enable composer.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable bigquery.googleapis.com
```

### Step 2 — Create BigQuery Dataset & Table
```bash
bq mk demo_dataset

bq mk --table demo_dataset.sales_data \
    id:INT64,name:STRING,amount:FLOAT
```

### Step 3 — Create GCS Bucket & Upload Data
```bash
gcloud storage buckets create gs://sales_bucket_akul
gcloud storage cp data/data.csv gs://sales_bucket_akul
```

### Step 4 — Deploy Airflow Environment (Composer)
```bash
# Takes ~20 mins to provision
gcloud composer environments create sampledemoairflowapp \
    --location us-central1 \
    --image-version composer-3-airflow-2.9.3-build.53
```

### Step 5 — Deploy the DAG
```bash
gcloud composer environments storage dags import \
    --environment sampledemoairflowapp \
    --location us-central1 \
    --source dags/etl_dag.py
```

### Step 6 — Query Results in BigQuery
```bash
bq query "SELECT * FROM demo_dataset.sales_data"
```

---

## 📊 Sample Data

The pipeline processes sales transaction records:

| id  | name     | amount |
|-----|----------|--------|
| 101 | Casselyn | 5000   |
| 102 | Zhining  | 3000   |
| 103 | Andika   | 7000   |
| 104 | MikiTong | 9000   |
| 105 | Jacub    | 4500   |

---

## 📝 DAG Details

| Property | Value |
|---|---|
| DAG ID | `batch_etl_demo` |
| Schedule | `@daily` |
| Source | `gs://sales_bucket_akul/data.csv` |
| Destination | `project.demo_dataset.sales_data` |
| Write Mode | `WRITE_TRUNCATE` (full refresh) |

---

## 🔧 Customisation

Before deploying, update these two values in `dags/etl_dag.py`:

```python
BUCKET_URI = "gs://YOUR_BUCKET_NAME/data.csv"
BQ_TABLE   = "YOUR_PROJECT_ID.demo_dataset.sales_data"
```

And update the DAG start date to today:
```python
start_date=datetime(2026, 4, 12),  # y, m, d
```

---

## 📚 Concepts Demonstrated

- **ETL Pipeline Design** — Extract from GCS, Load into BigQuery
- **Workflow Orchestration** — Apache Airflow DAGs on Cloud Composer
- **Cloud Data Warehousing** — BigQuery dataset/table creation and querying
- **Cloud Object Storage** — GCS bucket creation and file management
- **GCP IAM & APIs** — Enabling services and service account usage
- **Infrastructure via CLI** — Full setup using `gcloud` and `bq` CLI tools

