data "aws_iam_policy_document" "step1_lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "step1_lambda_log" {
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
      "${aws_cloudwatch_log_group.step1.arn}:*"
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
      aws_cloudwatch_log_group.step1.arn
    ]
  }
}

data "aws_iam_policy_document" "step1_lambda_sns" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = [
      var.sns_topic_arn
    ]
  }
}

resource "aws_iam_role" "step1_lambda" {
  name               = "${local.lambda_step1_name}-role"
  assume_role_policy = data.aws_iam_policy_document.step1_lambda_assume_policy.json
  tags = merge(
    var.tags,
    {
      "Name" = "${local.lambda_step1_name}-iam"
    }
  )
}

resource "aws_iam_role_policy" "step1_lambda_log" {
  name   = "CloudWatchLogsPolicy"
  role   = aws_iam_role.step1_lambda.id
  policy = data.aws_iam_policy_document.step1_lambda_log.json
}

resource "aws_iam_role_policy" "step1_lambda_sns" {
  name   = "SNSSendPolicy"
  role   = aws_iam_role.step1_lambda.id
  policy = data.aws_iam_policy_document.step1_lambda_sns.json
}