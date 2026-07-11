from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


DEFAULT_ARGS = {
    "owner": "hasanerenakin",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=3),
}


with DAG(
    dag_id="olist_reconstructed_pipeline",
    description="Orchestrates Spark ingestion and dbt Medallion transformations for the Olist pipeline.",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["olist", "spark", "dbt", "medallion"],
) as dag:

    check_required_containers = BashOperator(
        task_id="check_required_containers",
        bash_command="""
        docker ps | grep namenode
        docker ps | grep spark-master
        docker ps | grep spark-thriftserver
        docker ps | grep olist-dbt
        docker ps | grep superset
        echo 'Required containers are running.'
        """,
    )

    spark_ingestion_to_hdfs = BashOperator(
        task_id="spark_ingestion_csv_to_hdfs_parquet",
        bash_command="""
        docker exec spark-master /spark/bin/spark-submit \
          --master local[*] \
          /app/processing/csv_to_parquet.py
        """,
    )

    register_external_tables = BashOperator(
        task_id="register_external_spark_tables",
        bash_command="""
        docker exec spark-thriftserver /spark/bin/beeline \
          -u jdbc:hive2://localhost:10000/default \
          -f /app/processing/create_spark_tables.sql
        """,
    )

    dbt_debug = BashOperator(
        task_id="dbt_debug_connection",
        bash_command="""
        docker exec olist-dbt dbt debug \
          --project-dir /app/dbt_olist \
          --profiles-dir /app/dbt_olist
        """,
    )

    dbt_run = BashOperator(
        task_id="dbt_run_medallion_models",
        bash_command="""
        docker exec olist-dbt dbt run \
          --project-dir /app/dbt_olist \
          --profiles-dir /app/dbt_olist
        """,
    )

    dbt_test = BashOperator(
        task_id="dbt_test_gold_models",
        bash_command="""
        docker exec olist-dbt dbt test \
          --project-dir /app/dbt_olist \
          --profiles-dir /app/dbt_olist
        """,
    )

    register_existing_star_schema_views = BashOperator(
        task_id="register_existing_star_schema_views",
        bash_command="""
        docker exec spark-thriftserver /spark/bin/beeline \
          -u jdbc:hive2://localhost:10000/default \
          -f /app/processing/create_star_schema_views.sql
        """,
    )

    superset_ready_note = BashOperator(
        task_id="superset_dashboard_ready",
        bash_command="""
        echo 'Olist Dashboard can be reviewed at http://localhost:8088 after Spark and dbt models are ready.'
        """,
    )

    (
        check_required_containers
        >> spark_ingestion_to_hdfs
        >> register_external_tables
        >> dbt_debug
        >> dbt_run
        >> dbt_test
        >> register_existing_star_schema_views
        >> superset_ready_note
    )
