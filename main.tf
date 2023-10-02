terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Name       = var.name                   # this will be overridden if present in individual instances
      project    = var.name                   # no longer a local, and now a default tag
      terraform  = "true"                     # a default tag used to identify if these resources are terraformed, manual, or created somewhere else
      repository = "aws-terraform-deployment" # used to identify where these resources live in code (can be the full URL too)
    }
  }
}
