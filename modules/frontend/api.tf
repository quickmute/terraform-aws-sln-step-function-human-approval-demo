# YOU CAN go directly from API GW to Step, but I found going to Lambda to be more intuitive
# https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-api-gateway.html

# Create REST API
resource "aws_api_gateway_rest_api" "example" {
  name = local.api_name
  tags = merge(
    var.tags,
    {
      "Name" = var.api_name
    }
  )
}
# Create Resource in this REST API
resource "aws_api_gateway_resource" "example" {
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = local.api_resource_path
  rest_api_id = aws_api_gateway_rest_api.example.id
  ## no tags
}

###########################################################
# OPTIONS METHOD BLOCK
# This is typically generated for you in AWS Console
# The response models/parameters are typically injected for
# you as part of CORS configuration in AWS Console
###########################################################

resource "aws_api_gateway_method" "options" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  ## no tags
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
  ## no tags
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
  ## no tags
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    #we don't need all the methods, but here are the rest if you want
    #"method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
  ## no tags
}

###########################################################
# POST METHOD BLOCK
###########################################################

resource "aws_api_gateway_method" "post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  ## no tags
}

resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
  depends_on = [aws_api_gateway_method.post]
  ## no tags
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.example.id
  http_method             = aws_api_gateway_method.post.http_method
  content_handling        = "CONVERT_TO_TEXT"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.apigw_lambda.invoke_arn
  ## no tags
}

resource "aws_api_gateway_integration_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_200.status_code
  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [
    aws_api_gateway_method_response.post_200,
    aws_api_gateway_integration.post
  ]
  ## no tags
}

# DEPLOYMENT
resource "aws_api_gateway_deployment" "post" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example.id,
      aws_api_gateway_method.post.id,
      aws_api_gateway_integration.post.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  ## no tags
}

# Create PROD Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.post.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prod"
  tags = merge(
    var.tags,
    {
      "Name" = "prod"
    }
  )
}

# Return Invoke URL
# This needs to be written into JS file under S3/js
locals {
  invoke_url = aws_api_gateway_stage.prod.invoke_url
}
