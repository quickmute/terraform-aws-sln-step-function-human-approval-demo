# Just some basic housekeeping stuff
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_postfix = var.random_bit
  api_name     = "${var.api_name}-${local.name_postfix}"
  # truly unique bucketname
  bucket_name       = "${local.accountId}-${local.regionName}-${local.name_postfix}"
  lambda_name       = "${local.api_name}-lambda"
  api_resource_path = "execution"
  accountId         = data.aws_caller_identity.current.account_id
  regionName        = data.aws_region.current.name
}
