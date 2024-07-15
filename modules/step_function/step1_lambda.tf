# ZIP the lambda file
data "archive_file" "step1" {
  type             = "zip"
  source_dir       = "${path.module}/lambdas/step1/files"
  output_path      = "${path.module}/lambdas/step1/lambda.zip"
  output_file_mode = "0666"
}

# Create a Lambda function
resource "aws_lambda_function" "step1" {
  filename      = data.archive_file.step1.output_path
  function_name = local.lambda_step1_name
  role          = aws_iam_role.step1_lambda.arn
  handler       = "lambda_function.lambda_handler"
  architectures = ["arm64"]
  timeout       = 60
  runtime       = "python3.12"

  source_code_hash = data.archive_file.step1.output_base64sha256

  tags = merge(
    var.tags,
    {
      "Name" = local.lambda_step1_name
    }
  )

  environment {
    variables = {
      approver_sns_topic = var.sns_topic_arn
      foo                = "bar"
    }
  }
}

resource "aws_cloudwatch_log_group" "step1" {
  name              = "/aws/lambda/${local.lambda_step1_name}"
  retention_in_days = 30
  tags = merge(
    var.tags,
    {
      "Name" = local.lambda_step1_name
    }
  )
}