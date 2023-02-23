variable "common_tags" {
  description = "tags for resources"
  type        = map(string)
}

variable "aws_prefix" {
  description = "Prefix for AWS resource naming"
  type        = string
}

variable "AWS_ACCOUNT_ID" {
  description = "Your AWS Account ID without dashes"
  type        = string
}

variable "AWS_VPC_ID" {
  type = string
}

variable "AWS_SUBNETS" {
  type = list(string)
}
