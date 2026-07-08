from pathlib import Path
from pyspark.sql import SparkSession

LOCAL_INPUT_BASE = "/app/data/raw"
SPARK_INPUT_BASE = "file:///app/data/raw"
OUTPUT_BASE = "hdfs://namenode:9000/olist/parquet"

TABLES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

missing_files = []

for filename in TABLES.values():
    path = Path(LOCAL_INPUT_BASE) / filename
    if not path.exists():
        missing_files.append(str(path))

if missing_files:
    print("Missing files:")
    for file in missing_files:
        print(file)
    raise SystemExit(1)

spark = (
    SparkSession.builder
    .appName("Olist CSV to Parquet Phase 1")
    .config("spark.hadoop.fs.defaultFS", "hdfs://namenode:9000")
    .getOrCreate()
)

spark.sparkContext.setLogLevel("WARN")

for table_name, filename in TABLES.items():
    input_path = f"{SPARK_INPUT_BASE}/{filename}"
    output_path = f"{OUTPUT_BASE}/{table_name}"

    print(f"Reading {input_path}")

    df = (
        spark.read
        .option("header", "true")
        .option("inferSchema", "true")
        .option("multiLine", "true")
        .option("escape", '"')
        .csv(input_path)
    )

    print(f"Writing {output_path}")

    (
        df.write
        .mode("overwrite")
        .parquet(output_path)
    )

    print(f"Done: {table_name}")

spark.stop()

print("All CSV files were converted to Parquet successfully.")
