# Just some basic housekeeping stuff
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  suffix                   = var.random_bit
  accountId                = data.aws_caller_identity.current.account_id
  regionName               = data.aws_region.current.name
  step_function_name       = var.step_function_name
  step_function_definition = "${path.module}/step_definition/def.json"
  lambda_step1_name        = "${local.step_function_name}-lambda-step1"
  lambda_step2_name        = "${local.step_function_name}-lambda-step2"
  dynamodb_log_table_name  = split("/", var.dynamodb_log_table_arn)[1]
}