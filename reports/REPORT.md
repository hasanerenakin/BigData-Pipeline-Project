# Olist Big Data Analytics Pipeline Report

## 1. Project Goal

The goal of this project is to build an end-to-end big data analytics pipeline using the Olist Brazilian E-Commerce dataset.

The pipeline ingests raw CSV files, processes them with Apache Spark, stores the processed data in Parquet format on HDFS, exposes the data as Spark SQL tables, and visualizes the results using Apache Superset.

This project demonstrates how raw e-commerce data can be transformed into useful analytical information.

## 2. Dataset

The project uses the Olist Brazilian E-Commerce public dataset.

The input data consists of 9 CSV files:

- olist_customers_dataset.csv
- olist_geolocation_dataset.csv
- olist_order_items_dataset.csv
- olist_order_payments_dataset.csv
- olist_order_reviews_dataset.csv
- olist_orders_dataset.csv
- olist_products_dataset.csv
- olist_sellers_dataset.csv
- product_category_name_translation.csv

These files contain information about customers, orders, order items, payments, reviews, products, sellers, geolocation data, and product category translations.

## 3. Data Quality and Clean Data

Clean data means data that is accurate, consistent, complete enough for analysis, correctly typed, and free from unnecessary duplicate records.

For this project, the following data quality points were considered:

- Some columns contain missing values, especially delivery-related timestamp columns.
- Some tables naturally contain multiple rows for the same business entity. For example, one order can have multiple items and one order can have multiple payments. These are not incorrect duplicates.
- Product categories are originally in Portuguese, so the translation table is used to make category analysis easier.
- Date columns are cast to timestamp or date types when used in analytical queries.
- Delivered order analysis filters out records with missing delivery timestamps.
- Exact duplicate records should be removed in a production Silver layer if they exist.

Duplicate handling must be done carefully. For example, duplicate `order_id` values in `order_items` are expected because one order can contain multiple products. Therefore, the project does not blindly remove business-valid repeated records. Instead, duplicate checks should focus on the correct grain of each table.

## 4. Pipeline Architecture

The architecture of the project is:

Raw CSV files  
→ Apache Spark  
→ Parquet files  
→ HDFS  
→ Spark SQL Tables  
→ Apache Superset Dashboard

### Architecture Layers

The project can be explained using layered data architecture:

### Bronze Layer

The Bronze layer contains the raw CSV files.

Location:

data/raw/

This layer keeps the original source data unchanged.

### Silver Layer

The Silver layer contains processed Parquet files.

Location:

hdfs://namenode:9000/olist/parquet/

In this layer, CSV files are read by Spark and converted into Parquet format. Parquet is more efficient for analytical queries because it is columnar and compressed.

### Gold Layer

The Gold layer contains analytical Spark SQL tables and star schema views.

Files:

- processing/create_spark_tables.sql
- processing/create_star_schema_views.sql

This layer prepares the data for business questions and dashboard usage.

### Visualization Layer

Apache Superset is used as the visualization layer.

Dashboard:

Olist Dashboard

## 5. ETL / ELT Approach

This project mainly follows an ETL approach.

ETL means:

Extract → Transform → Load

In this project:

- Extract: Raw Olist CSV files are read from `data/raw/`.
- Transform: Apache Spark converts CSV files into Parquet format and prepares queryable Spark SQL tables.
- Load: The processed Parquet data is stored in HDFS and then used by Superset.

The transformation happens before the data is used for dashboarding. Therefore, ETL is a better description for this project.

An ELT approach would load raw data first into a data warehouse or lakehouse and transform it later using SQL-based tools. That approach is also common in modern analytics systems, especially when tools like dbt are used.

## 6. What is dbt?

dbt stands for data build tool.

dbt is used to transform data inside a data warehouse or lakehouse using SQL. It helps analytics engineers create reusable, version-controlled, and testable SQL models.

In a larger version of this project, dbt could be used to:

- Build dimension tables.
- Build fact tables.
- Create star schema models.
- Add data quality tests.
- Document the analytical model.
- Manage transformations in a reproducible way.

In this project, Spark SQL files are used instead of dbt, but the logic is similar: raw or processed data is transformed into analytical models that can answer business questions.

## 7. Data Processing

The raw dataset files were placed under:

data/raw/

A Spark processing script was created:

processing/csv_to_parquet.py

This script reads all 9 CSV files and writes them to HDFS in Parquet format.

Output path:

hdfs://namenode:9000/olist/parquet/

The generated Parquet folders are:

- /olist/parquet/customers
- /olist/parquet/geolocation
- /olist/parquet/orders
- /olist/parquet/order_items
- /olist/parquet/order_payments
- /olist/parquet/order_reviews
- /olist/parquet/products
- /olist/parquet/sellers
- /olist/parquet/category_translation

## 8. Spark SQL Tables

Spark SQL external tables were created from the Parquet files stored in HDFS.

SQL file:

processing/create_spark_tables.sql

Created tables:

- customers
- geolocation
- orders
- order_items
- order_payments
- order_reviews
- products
- sellers
- category_translation

These tables make it possible to query the processed data using SQL.

## 9. Star Schema Design

A star schema is an analytical data model that contains fact tables and dimension tables.

Fact tables store measurable business events, such as orders, payments, deliveries, and reviews.

Dimension tables store descriptive information, such as customers, products, sellers, payment types, and order statuses.

The project includes a star schema view script:

processing/create_star_schema_views.sql

### Dimension Tables

Proposed dimension views:

- dim_customer
- dim_seller
- dim_product
- dim_order_status
- dim_payment_type

### Fact Tables

Proposed fact views:

- fact_order_items
- fact_payments
- fact_delivery
- fact_review_items

### Star Schema Logic

The main business process is e-commerce ordering.

- `fact_order_items` supports product category revenue and seller performance analysis.
- `fact_payments` supports revenue and payment method analysis.
- `fact_delivery` supports delivery time analysis.
- `fact_review_items` supports review score analysis by product category.

These fact tables share common dimensions such as customer, product, seller, payment type, and order status.

## 10. Business Question Mapping

| Business Question | Fact Table | Dimensions |
|---|---|---|
| Monthly revenue | fact_payments | Date / order_purchase_timestamp |
| Revenue by product category | fact_order_items | dim_product |
| Top-performing sellers | fact_order_items | dim_seller |
| Sales by customer state | fact_payments | dim_customer |
| Average delivery time by state | fact_delivery | dim_customer |
| Payment method trends | fact_payments | dim_payment_type |
| Average review score by category | fact_review_items | dim_product |

## 11. Superset Dashboard

Apache Superset was connected to Spark ThriftServer using a Hive connection.

Database connection:

hive://hive@spark-thriftserver:10000/olist

The dashboard created in Superset is:

Olist Dashboard

The following charts were created:

1. Revenue by Payment Type
2. Orders by Status
3. Monthly Orders
4. Payment Method Trends
5. Monthly Revenue by Top Product Categories
6. Monthly Orders by Customer State
7. Monthly Revenue by Customer State
8. Order Status Trends
9. Monthly Average Delivery Time by State
10. Monthly Average Review Score by Category

These charts provide insight into revenue, payment behavior, order trends, product categories, customer states, delivery performance, and review scores.

## 12. Technologies Used

The following technologies were used:

- Docker
- Apache Spark
- HDFS
- Spark SQL
- Spark ThriftServer
- Apache Superset
- Python
- SQL
- Parquet

## 13. Notes

Docker was used to run the required services locally.

The raw dataset files are not committed to GitHub because they are large and should remain under data/raw locally.

Only the processing scripts, SQL files, report files, and visualization materials are included in the repository.

## 14. Conclusion

This project successfully implements an end-to-end big data analytics pipeline.

Raw Olist CSV files were ingested, converted to Parquet using Spark, stored in HDFS, exposed as Spark SQL tables, modeled with star schema views, and visualized in Superset.

The final dashboard provides useful insights into orders, revenue, payment methods, product categories, customer locations, delivery performance, and customer reviews.
