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

## 3. Pipeline Architecture

The architecture of the project is:

Raw CSV files  
→ Apache Spark  
→ Parquet files  
→ HDFS  
→ Spark SQL Tables  
→ Apache Superset Dashboard

### Components

- CSV files: Raw input data.
- Apache Spark: Reads the CSV files and converts them into Parquet format.
- Parquet: Stores processed data in an efficient columnar format.
- HDFS: Stores the processed Parquet files.
- Spark ThriftServer: Allows Superset to query Spark SQL tables.
- Apache Superset: Creates charts and dashboards for business analysis.

## 4. Data Processing

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

## 5. Spark SQL Tables

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

## 6. Superset Dashboard

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

## 7. Business Insights

The dashboard helps answer several business questions:

- Which payment methods generate the most revenue?
- How do orders change over time?
- Which product categories generate the most revenue?
- Which customer states contribute the most orders and revenue?
- How do order statuses change over time?
- How does delivery time vary by customer state?
- How do review scores change across product categories?

## 8. Technologies Used

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

## 9. Notes

Docker was used to run the required services locally.

The raw dataset files are not committed to GitHub because they are large and should remain under data/raw locally.

Only the processing scripts, SQL files, report files, and visualization materials are included in the repository.

## 10. Conclusion

This project successfully implements an end-to-end big data analytics pipeline.

Raw Olist CSV files were ingested, converted to Parquet using Spark, stored in HDFS, exposed as Spark SQL tables, and visualized in Superset.

The final dashboard provides useful insights into orders, revenue, payment methods, product categories, customer locations, delivery performance, and customer reviews.
