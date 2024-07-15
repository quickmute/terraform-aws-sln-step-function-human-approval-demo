variable "tags" {
  default     = {}
  description = "No tags for you"
}

variable "random_bit" {
  type        = string
  description = "(optional) Random Bit"
}

variable "step_function_name" {
  type        = string
  description = "(Required) Full name of this step function."
}

variable "sns_topic_arn" {
  type        = string
  description = "(optional) ARN of the SNS for approver"
}

variable "dynamodb_log_table_arn" {
  type        = string
  description = "(optional) dynamodb_table"
}

variable "apigw_endpoint" {
  type        = string
  description = "(optional) describe your variable"
}