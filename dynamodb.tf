locals {
  log_dynamodb_name = "approve-log-table-${random_pet.name.id}"
}
resource "aws_dynamodb_table" "log_table" {
  name         = local.log_dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  ## Just use generic PK (partition key) and SK (sort key)
  ## Let them be strings just cause
  hash_key  = "PK"
  range_key = "SK"
  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
}
