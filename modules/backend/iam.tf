## Create IAM Policy and Role for Lambda
data "aws_iam_policy_document" "lambda_cloudwatch_iam_policy" {
  version = "2012-10-17"

  ## This is for log stream
  statement {
    sid    = "CwLogging"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda.arn}:*"
    ]
  }

  ## This is for log group
  statement {
    sid    = "CwLogGroups"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:CreateLogGroup"
    ]
    resources = [
      aws_cloudwatch_log_group.lambda.arn
    ]
  }
}

data "aws_iam_policy_document" "lambda_step_iam_policy" {
  version = "2012-10-17"

  statement {
    sid    = "CwLogging"
    effect = "Allow"
    actions = [
      "states:SendTaskFailure",
      "states:SendTaskSuccess"
    ]
    resources = [
      "arn:aws:states:${local.regionName}:${local.accountId}:stateMachine:${var.step_function_name}"
    ]
  }
}



data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    sid     = "baseRoleAssumptionLambdaService"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${local.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
  tags = merge(
    var.tags,
    {
      "Name" = "${local.lambda_name}-role"
    }
  )
}

resource "aws_iam_role_policy" "lambda_cloudwatch" {
  name   = "CloudWatchLogsPolicy"
  role   = aws_iam_role.lambda_iam_role.name
  policy = data.aws_iam_policy_document.lambda_cloudwatch_iam_policy.json
}

resource "aws_iam_role_policy" "lambda_step" {
  name   = "StepFunctionPolicy"
  role   = aws_iam_role.lambda_iam_role.name
  policy = data.aws_iam_policy_document.lambda_step_iam_policy.json
}