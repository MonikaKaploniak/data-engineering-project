// IAM trust policy for EventBridge
data "aws_iam_policy_document" "eventbridge_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

// IAM role for EventBridge (optional in this flow, but included for flexibility)
resource "aws_iam_role" "eventbridge_role" {
  name               = "eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_trust_policy.json
}

// EventBridge rule to trigger every 30 minutes
resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name                = "trigger-step-function-every-30-minutes"
  schedule_expression = "rate(30 minutes)"
}

// EventBridge target that triggers the Step Function
resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.eventbridge_rule.name
  target_id = "trigger-step-function"
  arn       = aws_sfn_state_machine.step_function.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}

resource "aws_iam_role_policy" "eventbridge_invoke_step_function_policy" {
  name = "eventbridge_invoke_step_function_policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["states:StartExecution"],
        Resource = aws_sfn_state_machine.step_function.arn
      }
    ]
  })
}
