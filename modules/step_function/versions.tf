terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

## Define version for CLI Binary
terraform {
  required_version = ">= 0.14"
}
