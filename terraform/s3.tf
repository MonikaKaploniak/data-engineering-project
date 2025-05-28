resource "aws_s3_bucket" "ingestion_bucket" {
  bucket = var.ingestion_bucket_name
  force_destroy = true
}