variable "tags" {
  default     = {}
  description = "tags"
}

variable "subscriber_email_address" {
  type        = string
  description = "Provide your own email address here as the account owner"
}

variable "ip_address" {
  description = "This is your IP address or range of IP you want to test this from."
  type        = string
}
