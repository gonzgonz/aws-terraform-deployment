terraform {
  required_version = "~> 1.5"

  backend "s3" {
    # please modify the following "bucket" and "key" to match ones that you own, or comment out the whole block)
    bucket = "gonzaloarce-terraform-states"
    key    = "infrastructure-deployment"

    region  = "us-east-1"
    encrypt = true
    # dynamodb_table = "terraform-states-lock" # I recommend using a DDB lock file to prevent state taints or drifts
  }

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

locals {
}
