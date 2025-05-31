# Access Totesys using credentials (gitignore!)
# Look for changes in ToteSys and ingest new or updated data
# Store Totesys data into S3 ingest bucket
# Add logs to CloudWatch

import boto3
import logging
import os
import pg8000.native
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv


BUCKET = "my-ingestion-bucket-unique-name"
# Initialize the S3 client outside of the handler
s3_client = boto3.client('s3')

# Initialize the logger
logger = logging.getLogger()
logger.setLevel("INFO")

# Load environment variables
load_dotenv()

# ENV VARIABLES
COHORT_ID = os.environ["TOTESYS_COHORT_ID"]
USER = os.environ["TOTESYS_USER"]
PASSWORD = os.environ["TOTESYS_PASSWORD"]
HOST = os.environ["TOTESYS_HOST"]
DATABASE = os.environ["TOTESYS_DATABASE"]
PORT = os.environ["TOTESYS_PORT"]

TABLES = ["counterparty", "currency", "department", "design", "staff", "sales_order", "address", "payment", "purchase_order", "payment_type", "transaction"]

def lambda_handler(event, context):
    timestamp = datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S") # formats it as a string like "2025-05-29-12-00-00"
    try:
        print("Connecting to database...")
        conn = pg8000.native.Connection(
            # cohort_id=COHORT_ID,
            user=USER,
            password=PASSWORD,
            host=HOST,
            database=DATABASE,
            port=PORT
        )
        for table in TABLES:
            rows = conn.run(f"SELECT * FROM {table}")
            columns = [col['name'] for col in conn.columns]
            df = pd.DataFrame(rows, columns=columns)

            print("Writing to S3...")
            s3_client.put_object(
                Bucket=BUCKET,
                Key=f"{timestamp}/{table}.csv",
                Body=df.to_csv(index=False)
            )

        logger.info("Successfully uploaded tables to the bucket")
        return {"statusCode": 200, "body": f"Uploaded {len(TABLES)} tables to S3 {BUCKET}"}
    except Exception as e:
        logger.error(f"Error processing order: {str(e)}")
        raise
    finally:
        if "conn" in locals():
            conn.close()
            # This means: If the variable conn exists in the current local scope (i.e., the connection was successfully created), then close it.

# connected to the Totesys PostgreSQL database using credentials from environment variables, 
# selected and extracted data from multiple tables, 
# stored it in an S3 ingestion bucket as CSV files, and 
# added logging to CloudWatch - Lambda function automatically adds logs to CloudWatch 
# through the use of Python’s built-in logging module — and AWS handles the rest

# Behind the scenes:
# Every AWS Lambda function automatically sends all stdout and stderr output 
# — including anything from print() or logging — to Amazon CloudWatch Logs.
# When your function runs, AWS creates (or appends to) a log stream in 
# a log group named /aws/lambda/<your-lambda-name>.