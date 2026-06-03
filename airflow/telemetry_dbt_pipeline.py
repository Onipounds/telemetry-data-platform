from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator

DBT = "/home/airflow/.local/bin/dbt"
PROJECT = "/opt/airflow/telemetry_dbt"
PROFILES = "/opt/airflow/dbt_profiles"
TARGET = "docker"

with DAG(
    dag_id="telemetry_dbt_pipeline",
    description="Build and test the telemetry dbt models",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["dbt", "telemetry"],
) as dag:

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"{DBT} run "
            f"--project-dir {PROJECT} "
            f"--profiles-dir {PROFILES} "
            f"--target {TARGET}"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"{DBT} test "
            f"--project-dir {PROJECT} "
            f"--profiles-dir {PROFILES} "
            f"--target {TARGET}"
        ),
    )

    dbt_run >> dbt_test