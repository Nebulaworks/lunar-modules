terraform {
  required_version = ">=1.3.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.30.0"
    }
  }
}
