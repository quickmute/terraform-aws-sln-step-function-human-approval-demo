variable "myip" {
  description = "This is your IP address or range of IP you want to test this from."
}

variable "random_bit" {
  type        = string
  description = "(optional) Random Bit"
}

variable "api_name" {
  default     = "approverFront"
  description = "Name of your Gateway API resource"
}

variable "tags" {
  default     = {}
  description = "No tags for you"
}

variable "stepFunction_arn" {
  description = "ARN of StepFunction"
  type        = string
}

variable "log_dynamodb_arn" {
  description = "ARN of DynamoDB used for logging purposed"
  type        = string
}