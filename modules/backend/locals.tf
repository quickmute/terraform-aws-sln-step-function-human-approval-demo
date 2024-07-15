# Just some basic housekeeping stuff
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_postfix = var.random_bit
  accountId    = data.aws_caller_identity.current.account_id
  regionName   = data.aws_region.current.name
}

# Return Invoke URL
# This will be used to build the URL that will be in the SNS message
locals {
  step_invoke_apiGWEndpoint = aws_api_gateway_stage.default.invoke_url
  lambda_name               = "${var.lambda_name}-${local.name_postfix}"
}
