variable "random_bit" {
  type        = string
  description = "(optional) Random Bit"
}

variable "api_name" {
  default     = "step_function_approver"
  description = "Name of your Gateway API resource"
}

variable "step_function_name" {
  type        = string
  description = "(Required) Full name of this step function."
}

variable "api_resource_path" {
  default     = "execution"
  description = "Resource Path"
}

variable "lambda_name" {
  default     = "step-approval"
  description = "lambda name"
}

variable "lambda_return_url" {
  default     = "https://www.google.com"
  description = "Redirect target after approving has been done"
  type        = string
}

variable "tags" {
  default     = {}
  description = "tags"
}