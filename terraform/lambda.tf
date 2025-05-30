# Define resource "aws_lambda_function"

resource "aws_lambda_function" "ingestion_lambda" {
  function_name    = var.ingestion_lambda_name
  s3_bucket        = var.ingestion_bucket_name     # e.g., "terrific-totes-code-bucket"
  s3_key           = "lambda/ingestion/lambda.zip" # e.g., "lambda/ingestion/lambda.zip"
  handler          = "ingestion.ingestion_lambda_handler.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30
}
# This resource allows you to define and manage AWS Lambda functions using Terraform. It supports specifying various attributes such as:

# function_name: The name of the Lambda function.
# filename: The path to the deployment package (ZIP file).
# handler: The function within your code that Lambda calls to begin execution.
# runtime: The runtime environment for the Lambda function (e.g., python3.12).
# role: The Amazon Resource Name (ARN) of the IAM role that Lambda assumes when it executes your function.
# source_code_hash: A base64-encoded SHA256 hash of the deployment package. Terraform uses this to determine when to update the function.
