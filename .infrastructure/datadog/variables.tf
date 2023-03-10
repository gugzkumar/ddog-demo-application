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

variable "DATADOG_API_KEY" {
  description = "Value of API key for the Datadog provider"
  type        = string
}
