## use this random bits to ensure we don't get any collision from someone's test code
resource "random_pet" "name" {
  length = 1
}

locals {
  ## We define the full name of step function outside of step module because
  ## both step and backend needs this name for building policy
  step_function_name = "HumanApprovalStepFunction-${random_pet.name.id}"
}

module "backend" {
  source             = "./modules/backend"
  random_bit         = random_pet.name.id
  step_function_name = local.step_function_name
  tags               = var.tags
}

output "apigw_backend" {
  value = module.backend.apigw_endpoint
}

module "step_function" {
  source                 = "./modules/step_function"
  step_function_name     = local.step_function_name
  random_bit             = random_pet.name.id
  sns_topic_arn          = aws_sns_topic.sns_topic.arn
  dynamodb_log_table_arn = aws_dynamodb_table.log_table.arn
  apigw_endpoint         = module.backend.apigw_endpoint
  tags                   = var.tags
}

## MUST run twice for the changes to S3 file to be uploaded
## When you run first time, your config.js will not be uploaded, because your TF is creating it
## When you run second time, your config.js will be uplaoded because it now exists
module "frontend" {
  source           = "./modules/frontend"
  random_bit       = random_pet.name.id
  stepFunction_arn = module.step_function.stepfunction_arn
  log_dynamodb_arn = aws_dynamodb_table.log_table.arn
  myip             = var.ip_address
  tags             = var.tags
}

output "web_frontend" {
  value = module.frontend.website
}