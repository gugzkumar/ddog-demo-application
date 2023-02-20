variable "common_tags" {
  description = "tags for resources"
  type        = map(string)
}

variable "aws_prefix" {
  description = "Prefix for AWS resource naming"
  type        = string
}
