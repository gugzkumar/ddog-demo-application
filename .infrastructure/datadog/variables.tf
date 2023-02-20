variable "common_tags" {
  description = "tags for resources"
  type        = map(string)
}

variable "AWS_ACCOUNT_ID" {
  description = "Your AWS Account ID without dashes"
  type        = string
}
