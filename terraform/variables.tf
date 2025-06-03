variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "ingestion_bucket_name" {
  default = "my-ingestion-bucket-unique-name"
}

variable "ingestion_lambda_name" {
  description = "The name of the ingestion Lambda function"
  type        = string
  default     = "monika-test-ingestion-lambda"
}

variable "cohort_id" {
  description = "TOTESYS cohort ID"
  type        = string
}

variable "user" {
  description = "TOTESYS database user"
  type        = string
}

variable "password" {
  description = "TOTESYS database password"
  type        = string
  sensitive   = true
}

variable "host" {
  description = "TOTESYS database host"
  type        = string
}

variable "database" {
  description = "TOTESYS database name"
  type        = string
}

variable "port" {
  description = "TOTESYS database port"
  type        = string
  default     = "5432"
}