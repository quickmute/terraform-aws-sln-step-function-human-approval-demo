# ZIP the lambda file
data "archive_file" "apigw_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda/apigw_lambda.zip"
  source_dir  = "${path.module}/lambda/files"
}

# Create a Lambda function
resource "aws_lambda_function" "apigw_lambda" {
  filename      = "${path.module}/lambda/apigw_lambda.zip"
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  architectures = ["arm64"]
  timeout       = 60
  runtime       = "python3.12"

  source_code_hash = data.archive_file.apigw_lambda.output_base64sha256

  tags = merge(
    var.tags,
    {
      "Name" = "${local.lambda_name}"
    }
  )

  environment {
    variables = {
      foo              = "bar"
      stepFunction_arn = var.stepFunction_arn
      log_dynamodb_arn = var.log_dynamodb_arn
      referer_address  = local.bucket_name
      referer_host     = aws_api_gateway_rest_api.example.id
    }
  }
}

# This is a resource permission that API GW will normally attach for you if you did this from AWS Console

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.apigw_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.regionName}:${local.accountId}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.post.http_method}${aws_api_gateway_resource.example.path}"
  ## no tags
}

resource "aws_cloudwatch_log_group" "apigw_lambda" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 30
  tags = merge(
    var.tags,
    {
      "Name" = local.lambda_name
    }
  )
}
