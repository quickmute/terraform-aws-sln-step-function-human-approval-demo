data "aws_iam_policy_document" "step2_lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "step2_lambda_log" {
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
      "${aws_cloudwatch_log_group.step2.arn}:*"
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
      aws_cloudwatch_log_group.step2.arn
    ]
  }
}

resource "aws_iam_role" "step2_lambda" {
  name               = "${local.lambda_step2_name}-role"
  assume_role_policy = data.aws_iam_policy_document.step2_lambda_assume_policy.json
  tags = merge(
    var.tags,
    {
      "Name" = "${local.lambda_step2_name}-iam"
    }
  )
}

resource "aws_iam_role_policy" "step2_lambda_log" {
  name   = "CloudWatchLogsPolicy"
  role   = aws_iam_role.step2_lambda.id
  policy = data.aws_iam_policy_document.step2_lambda_log.json
}