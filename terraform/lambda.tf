# Define resource "aws_lambda_function"

resource "aws_lambda_function" "ingestion_lambda" {
  function_name = var.ingestion_lambda_name
  s3_bucket     = var.ingestion_bucket_name     # e.g., "terrific-totes-code-bucket"
  s3_key        = "lambda/ingestion/lambda.zip" # e.g., "lambda/ingestion/lambda.zip"
  handler       = "src.ingestion.ingestion_lambda_handler.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60
  layers = [aws_lambda_layer_version.common_layer.arn, # custom layer with pg8000
  "arn:aws:lambda:eu-west-2:336392948345:layer:AWSSDKPandas-Python311:2"]
  
  environment {
    variables = {
      TOTESYS_COHORT_ID = "de_2025_03_17"
      TOTESYS_USER = "project_team_014"
      TOTESYS_PASSWORD = "h2ZulZOc8T1ctU4"
      TOTESYS_HOST = "nc-data-eng-totesys-production.chpsczt8h1nu.eu-west-2.rds.amazonaws.com"
      TOTESYS_DATABASE = "totesys"
      TOTESYS_PORT = "5432"
    }
  } # AWS-provided pandas public layer (AWSSDKPandas-Python311)
}
# This resource allows you to define and manage AWS Lambda functions using Terraform. It supports specifying various attributes such as:

# function_name: The name of the Lambda function.
# filename: The path to the deployment package (ZIP file).
# handler: The function within your code that Lambda calls to begin execution.
# runtime: The runtime environment for the Lambda function (e.g., python3.11).
# role: The Amazon Resource Name (ARN) of the IAM role that Lambda assumes when it executes your function.
# source_code_hash: A base64-encoded SHA256 hash of the deployment package. Terraform uses this to determine when to update the function.

resource "aws_lambda_layer_version" "common_layer" {
  layer_name          = "common-layer"
  compatible_runtimes = ["python3.11"]
  s3_bucket           = var.ingestion_bucket_name
  s3_key              = "lambda/layers/layer.zip"
}