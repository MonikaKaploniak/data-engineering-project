variable "aws_region" {
    description = "AWS region to deploy resources in"
    type        = string
    default = "eu-west-2"
}

variable "ingestion_bucket_name" {
    default = "my-ingestion-bucket-unique-name"
}

variable "ingestion_lambda_name" {
  description = "The name of the ingestion Lambda function"
  type        = string
  default     = "my_ingestion_lambda"
}