# Step Function Role
data "aws_iam_policy_document" "step_func_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "step_func_role_lambda_invoke_policy_document" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      aws_lambda_function.step1.arn,
      aws_lambda_function.step2.arn
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "step_func_role_dynamodb_policy_document" {
  statement {
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      var.dynamodb_log_table_arn
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "step_func_role" {
  name               = "${local.step_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.step_func_role_policy_document.json
}

resource "aws_iam_role_policy" "step_func_invoke_lambda" {
  name   = "invokelambda"
  role   = aws_iam_role.step_func_role.id
  policy = data.aws_iam_policy_document.step_func_role_lambda_invoke_policy_document.json
}

resource "aws_iam_role_policy" "step_func_write_dynamodb" {
  name   = "dynamodb"
  role   = aws_iam_role.step_func_role.id
  policy = data.aws_iam_policy_document.step_func_role_dynamodb_policy_document.json
}
