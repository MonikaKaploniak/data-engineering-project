# ---------------
# Lambda IAM Role
# ---------------
# create LAmbda role

# Define
data "aws_iam_policy_document" "trust_policy" {
    statement {
        effect = "Allow"

    principals {
        type = "Service"
        identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Create
resource "aws_iam_role" "lambda_role" {
    name_prefix = "role-${var.ingestion_lambda_name}"
    assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

# ------------------------------
# Lambda IAM Policy for S3 Write
# ------------------------------
# give Lambda permission to write to S3

# Define


data "aws_iam_policy_document" "s3_data_policy_doc" {
  statement {
    # give permission to put objects in the data bucket
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.ingestion_bucket.arn}/*"]
  }
}

# Create
resource "aws_iam_policy" "s3_write_policy" {
    name_prefix = "s3-policy-${var.ingestion_lambda_name}-write"
    policy = data.aws_iam_policy_document.s3_data_policy_doc.json # using the policy document defined above
}

# Attach
resource "aws_iam_role_policy_attachment" "lambda_s3_write_policy_attachment" {
    # attach the s3 write policy to the lambda role
    policy_arn = aws_iam_policy.s3_write_policy.arn
    role = aws_iam_role.lambda_role.name
}

# ------------------------------
# Lambda IAM Policy for CloudWatch
# ------------------------------
# give Lambda permission to write logs to CloudWatch

# Define
data "aws_iam_policy_document" "cw_document" {
    statement {
    # give permission to create Log Groups in your account
        effect = "Allow"
        actions = [
        "logs:CreateLogGroup"
        ]
        resources = ["arn:aws:logs:*:*:*"] # all CloudWatch log resources in all regions and all accounts (region, account id, resource path)
    }

    statement {
    # give permission to create Log Streams and put Log Events in the lambda's own Log Group
        effect = "Allow"
        actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        ]
        resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/${var.ingestion_lambda_name}:*"]
    }
}

# Create
resource "aws_iam_policy" "cw_policy" {
    # use the policy document defined above
    name_prefix = "cw-policy-${var.ingestion_lambda_name}"
    policy = data.aws_iam_policy_document.cw_document.json
}

# Attach
resource "aws_iam_role_policy_attachment" "lambda_cw_policy_attachment" {
    # attach the cw policy to the lambda role
    policy_arn = aws_iam_policy.cw_policy.arn
    role = aws_iam_role.lambda_role.name
}