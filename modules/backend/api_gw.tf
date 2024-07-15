# Create REST API
resource "aws_api_gateway_rest_api" "default" {
  name = "${var.api_name}-${local.name_postfix}"
  tags = merge(
    var.tags,
    {
      "Name" = var.api_name
    }
  )
}
# Create Resource in this REST API
resource "aws_api_gateway_resource" "default" {
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = var.api_resource_path
  rest_api_id = aws_api_gateway_rest_api.default.id
  ## no tags
}

resource "aws_api_gateway_method" "default" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  ## no tags
}

resource "aws_api_gateway_method_response" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
  status_code = "302"
  response_parameters = {
    "method.response.header.Location" = true
  }
  ## no tags
}

resource "aws_api_gateway_integration" "default" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.default.id
  http_method             = aws_api_gateway_method.default.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda.invoke_arn

  request_templates = {
    "application/json" = <<RequestTemplates
{
  "body" : $input.json('$'),
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))" #if($foreach.hasNext),#end

    #end
  },
  "method": "$context.httpMethod",
  "params": {
    #foreach($param in $input.params().path.keySet())
    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end

    #end
  },
  "query": {
    #foreach($queryParam in $input.params().querystring.keySet())
    "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))" #if($foreach.hasNext),#end

    #end
  }  
}

    RequestTemplates
  }
  ## no tags
}

resource "aws_api_gateway_integration_response" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
  status_code = aws_api_gateway_method_response.default.status_code

  response_parameters = {
    "method.response.header.Location" = "integration.response.body.headers.Location"
  }
  depends_on = [aws_api_gateway_method_response.default]
  ## no tags
}

# DEPLOYMENT
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.default.id,
      aws_api_gateway_method.default.id,
      aws_api_gateway_integration.default.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  ## no tags
}

# Create states Stage
resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = "states"
  tags = merge(
    var.tags,
    {
      "Name" = "states"
    }
  )
}

