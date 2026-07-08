"""
Helper script for registering Spark SQL tables for Superset.

The actual table registration SQL is stored in:

processing/create_spark_tables.sql

This helper runs the SQL file through Spark ThriftServer using Beeline.
It should be executed from the project root after Docker services are running.
"""

import subprocess


def main():
    command = [
        "docker",
        "exec",
        "spark-thriftserver",
        "/spark/bin/beeline",
        "-u",
        "jdbc:hive2://localhost:10000/default",
        "-f",
        "/app/processing/create_spark_tables.sql",
    ]

    print("Registering Spark SQL tables for Superset...")
    subprocess.run(command, check=True)
    print("Table registration completed.")


if __name__ == "__main__":
    main()
