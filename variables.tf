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
