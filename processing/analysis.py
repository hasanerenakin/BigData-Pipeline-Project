"""
Optional analysis entry point for the Olist Big Data Analytics Pipeline.

Main project files:
- processing/csv_to_parquet.py:
  Reads raw Olist CSV files and writes them to HDFS in Parquet format.

- processing/create_spark_tables.sql:
  Registers Spark SQL external tables from the Parquet files.

- visualization/register_tables.py:
  Helper script for registering tables through Spark ThriftServer.

- reports/REPORT.md:
  Contains the project architecture, processing steps, dashboard information,
  and business insights.

The main analysis output of this project is the Superset dashboard and the
visualization screenshots under visualization/screenshots/.
"""


def main():
    print("Olist Big Data Analytics Pipeline")
    print("Main processing script: processing/csv_to_parquet.py")
    print("Table registration SQL: processing/create_spark_tables.sql")
    print("Project report: reports/REPORT.md")
    print("Dashboard screenshots: visualization/screenshots/")


if __name__ == "__main__":
    main()
