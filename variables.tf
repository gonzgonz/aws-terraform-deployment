variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS Region this module will manage resources into"

}

variable "name" {
  type        = string
  default     = "cint-code-test"
  description = "Root name for resources in this project"
}

variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC cidr block"
}

variable "newbits" {
  default     = 8
  type        = number
  description = "How many bits to extend the VPC cidr block by for each subnet"
}

variable "public_subnet_count" {
  default     = 3
  type        = number
  description = "How many subnets to create"
}

variable "private_subnet_count" {
  default     = 3
  type        = number
  description = "How many private subnets to create"
}

variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "root"
}

# this is not optimal but i'm trying to be pragmatic here, we should probably use SSM or secrets manager instead
# at least the value won't be commited into code, and is meant to be stored encrypted somewher else.
variable "rds_password" {
  description = "Password for the RDS instance"
  type        = string
}
