# Reconstructed Data Pipeline Architecture

## Objective

This document explains the reconstructed Olist data pipeline.

The reconstruction focuses on two main improvements:

1. Apache Airflow is added as an orchestration layer.
2. dbt is added as a transformation layer to organize the pipeline into a Medallion Architecture.

The new pipeline structure is:

Raw CSV Files
→ Apache Spark
→ HDFS Parquet
→ Spark SQL External Tables
→ dbt Bronze / Silver / Gold Models
→ Superset Dashboard

---

## Airflow Orchestration

Apache Airflow is used to automate, schedule, and monitor the pipeline workflow.

The DAG file is:

orchestration/dags/olist_reconstructed_pipeline.py

The DAG name is:

olist_reconstructed_pipeline

### Airflow Task Flow

The DAG contains the following tasks:

1. check_required_containers
2. spark_ingestion_csv_to_hdfs_parquet
3. register_external_spark_tables
4. dbt_debug_connection
5. dbt_run_medallion_models
6. dbt_test_gold_models
7. register_existing_star_schema_views
8. superset_dashboard_ready

The workflow is designed as a linear dependency chain because each step depends on the successful output of the previous step.

---

## Airflow Task Boundaries

### 1. check_required_containers

This task checks whether required Docker containers are running.

Required containers include:

- namenode
- spark-master
- spark-thriftserver
- olist-dbt
- superset

Operator:

BashOperator

Reason:

The task runs a shell command to verify container availability before starting the pipeline.

---

### 2. spark_ingestion_csv_to_hdfs_parquet

This task runs the Spark ingestion job.

Input:

data/raw/

Output:

hdfs://namenode:9000/olist/parquet/

Script:

processing/csv_to_parquet.py

Operator:

BashOperator

Reason:

The task executes spark-submit inside the Spark container.

---

### 3. register_external_spark_tables

This task registers the Parquet outputs as Spark SQL external tables.

SQL file:

processing/create_spark_tables.sql

Operator:

BashOperator

Reason:

The task runs Beeline against Spark ThriftServer.

---

### 4. dbt_debug_connection

This task validates the dbt connection to Spark ThriftServer.

Command:

dbt debug

Operator:

BashOperator

Reason:

It confirms that dbt can connect before transformations are executed.

---

### 5. dbt_run_medallion_models

This task runs the dbt Bronze, Silver, and Gold models.

Command:

dbt run

Operator:

BashOperator

Reason:

dbt transformations are executed through the dbt container.

---

### 6. dbt_test_gold_models

This task runs dbt tests for the analytical models.

Command:

dbt test

Operator:

BashOperator

Reason:

It validates important fields such as primary identifiers and non-null metrics.

---

### 7. register_existing_star_schema_views

This task runs the existing Spark SQL star schema view script.

SQL file:

processing/create_star_schema_views.sql

Operator:

BashOperator

Reason:

It keeps compatibility with the previous star schema views already used by the Superset dashboard.

---

### 8. superset_dashboard_ready

This task marks the dashboard layer as ready.

Output:

Olist Dashboard can be reviewed in Superset.

Operator:

BashOperator

Reason:

This is a lightweight terminal task that documents the final stage of the pipeline.

---

## dbt Medallion Architecture

The dbt project is located under:

dbt_olist/

The model layers are:

dbt_olist/models/bronze/
dbt_olist/models/silver/
dbt_olist/models/gold/

---

## Bronze Layer

The Bronze layer represents raw source tables registered in Spark SQL.

Bronze models are close to the original data and do not apply major transformations.

Examples:

- bronze_customers
- bronze_orders
- bronze_order_items
- bronze_order_payments
- bronze_products
- bronze_sellers

Purpose:

- Preserve the source structure.
- Provide a stable input layer for downstream transformations.
- Separate raw data access from cleaning logic.

---

## Silver Layer

The Silver layer cleans and standardizes the data.

Main transformations:

- Cast numeric columns to proper types.
- Cast date columns to timestamp/date types.
- Remove invalid null keys.
- Standardize city and state fields.
- Prepare category translation.
- Aggregate geolocation data by zip code prefix.

Examples:

- silver_customers
- silver_orders
- silver_order_items
- silver_order_payments
- silver_products
- silver_geolocation

Purpose:

- Improve data quality.
- Create clean boundaries between raw data and analytics-ready data.
- Make joins and analytical queries more reliable.

---

## Gold Layer

The Gold layer contains business-facing fact and dimension models.

Dimension models:

- dim_customer
- dim_seller
- dim_product
- dim_order_status
- dim_payment_type
- dim_geolocation

Fact models:

- fact_order_items
- fact_payments
- fact_delivery
- fact_review_items

Purpose:

- Support business questions.
- Provide star schema models for analytics.
- Make Superset dashboard queries easier and more consistent.

---

## Star Schema Design

The Gold layer follows star schema logic.

Fact views store measurable business events:

- payments
- order items
- delivery durations
- review scores

Dimension views store descriptive business attributes:

- customers
- sellers
- products
- payment types
- order statuses
- geolocation

This structure supports the following business questions:

| Business Question | Fact Model | Dimension Model |
|---|---|---|
| Monthly revenue | fact_payments | order_purchase_timestamp |
| Revenue by product category | fact_order_items | dim_product |
| Top-performing sellers | fact_order_items | dim_seller |
| Sales by customer state | fact_payments | dim_customer |
| Average delivery time by state | fact_delivery | dim_customer |
| Payment method trends | fact_payments | dim_payment_type |
| Average review score by category | fact_review_items | dim_product |

---

## Benefits of the Reconstructed Architecture

The reconstructed pipeline provides several benefits:

1. Automation

Airflow makes the pipeline repeatable and easier to monitor.

2. Clear task boundaries

Each pipeline step has a dedicated task and responsibility.

3. Modularity

dbt separates transformations into Bronze, Silver, and Gold layers.

4. Data quality

dbt tests help validate important analytical fields.

5. Maintainability

New models and transformations can be added without rewriting the full pipeline.

6. Analytical readiness

The Gold layer provides clean fact and dimension models for dashboards.

---

## Challenging Parts

The main challenges of this reconstruction were:

1. Connecting multiple containers

Airflow, dbt, Spark, HDFS, and Superset must communicate through the same Docker network.

2. Preserving existing pipeline compatibility

The previous Spark and Superset setup had to continue working while dbt and Airflow were added.

3. Designing clean data boundaries

The Bronze, Silver, and Gold layers required clear definitions to avoid mixing raw and business-ready logic.

4. Handling Spark and dbt integration

dbt connects to Spark through Spark ThriftServer, so the external Spark SQL tables must exist before dbt models run.

5. Defining correct model grain

Fact and dimension models must respect the business meaning of the data. For example, repeated order IDs in order items are valid because one order can contain multiple products.

---

## Conclusion

The reconstructed pipeline improves the original project by adding orchestration, modular transformations, and clearer data architecture.

Apache Airflow manages the workflow, dbt organizes the transformations into Medallion layers, Spark handles large-scale processing, HDFS stores Parquet outputs, and Superset provides the final dashboard layer.
