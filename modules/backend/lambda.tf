# ZIP the lambda file
data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda/example.zip"
  source_dir  = "${path.module}/lambda/files"
}

# Create a Lambda function
resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/lambda/example.zip"
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "lambda_function.lambda_handler"
  architectures = ["arm64"]
  timeout       = 60
  runtime       = "python3.12"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = merge(
    var.tags,
    {
      "Name" = var.lambda_name
    }
  )

  environment {
    variables = {
      foo        = "bar",
      return_url = var.lambda_return_url
    }
  }
}

# This is a resource permission that API GW will normally attach for you if you did this from AWS Console

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.regionName}:${local.accountId}:${aws_api_gateway_rest_api.default.id}/*"
  ## no tags
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 30
  tags = merge(
    var.tags,
    {
      "Name" = local.lambda_name
    }
  )
}