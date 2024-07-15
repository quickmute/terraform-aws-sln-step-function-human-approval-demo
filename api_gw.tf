# This is needed once per account per region
resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.apig_gw_cloudwatch.arn
}

data "aws_iam_policy_document" "api_gw_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apig_gw_cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.api_gw_assume_role.json
}

data "aws_iam_policy_document" "apig_gw_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "apig_gw_cloudwatch" {
  name   = "default"
  role   = aws_iam_role.apig_gw_cloudwatch.id
  policy = data.aws_iam_policy_document.apig_gw_cloudwatch.json
}