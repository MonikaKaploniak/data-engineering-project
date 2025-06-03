// Trust policy for Step Functions
data "aws_iam_policy_document" "step_function_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

// IAM role for Step Functions
resource "aws_iam_role" "step_function_role" {
  name               = "step-function-role"
  assume_role_policy = data.aws_iam_policy_document.step_function_trust_policy.json
}

// IAM policy to allow Step Functions to invoke the ingestion Lambda
resource "aws_iam_policy" "step_function_lambda_invoke_policy" {
  name = "step-function-lambda-invoke-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["lambda:InvokeFunction"],
        Resource = "${aws_lambda_function.ingestion_lambda.arn}:*"
      }
    ]
  })
}

// Attach the invoke policy to the Step Function role
resource "aws_iam_role_policy_attachment" "step_function_lambda_access" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_lambda_invoke_policy.arn
}

// Step Function to orchestrate ingestion Lambda
resource "aws_sfn_state_machine" "step_function" {
  name     = "step-function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    StartAt = "CallLambda",
    States = {
      CallLambda = {
        Type     = "Task",
        Resource = "${aws_lambda_function.ingestion_lambda.arn}",
        End      = true
      }
    }
  })
}

resource "aws_lambda_permission" "allow_stepfunctions" {
  statement_id  = "AllowStepFunctionsInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion_lambda.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.step_function.arn
}
