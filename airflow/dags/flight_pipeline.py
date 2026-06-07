from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import pandas as pd
from sqlalchemy import create_engine, text

# ── Config ──────────────────────────────────────────────────
DB_URL    = "postgresql://admin:admin123@127.0.0.1:5433/flights_db"
CSV_PATH  = "/Users/nitishbhattad/Desktop/flight-pipeline/data/raw/flights_raw.csv"
DBT_PATH  = "/Users/nitishbhattad/Desktop/flight-pipeline/dbt_project"
# ────────────────────────────────────────────────────────────

default_args = {
    "owner": "nitish",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

def validate_csv(**context):
    import os
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"CSV not found at {CSV_PATH}")
    df = pd.read_csv(CSV_PATH, nrows=5)
    print(f"✅ CSV valid — columns: {list(df.columns)}")

def check_row_count(**context):
    engine = create_engine(DB_URL)
    with engine.connect() as conn:
        count = conn.execute(
            text("SELECT COUNT(*) FROM raw.flights_raw")
        ).scalar()
    if count < 1000:
        raise ValueError(f"❌ Too few rows: {count}")
    print(f"✅ Row count OK: {count:,} rows")

with DAG(
    dag_id="flight_data_pipeline",
    default_args=default_args,
    description="ELT pipeline: CSV → PostgreSQL → dbt models",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@monthly",
    catchup=False,
    tags=["flights", "elt", "dbt"]
) as dag:

    validate = PythonOperator(
        task_id="validate_csv_file",
        python_callable=validate_csv
    )

    quality_check = PythonOperator(
        task_id="check_row_count",
        python_callable=check_row_count
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"cd {DBT_PATH} && dbt seed"
    )

    dbt_run = BashOperator(
        task_id="dbt_run_all_models",
        bash_command=f"cd {DBT_PATH} && dbt run"
    )

    dbt_test = BashOperator(
        task_id="dbt_test_all_models",
        bash_command=f"cd {DBT_PATH} && dbt test"
    )

    dbt_docs = BashOperator(
        task_id="dbt_generate_docs",
        bash_command=f"cd {DBT_PATH} && dbt docs generate"
    )

    # Pipeline order
    validate >> quality_check >> dbt_seed >> dbt_run >> dbt_test >> dbt_docs
