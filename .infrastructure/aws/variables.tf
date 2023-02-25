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

variable "datadog_agent_task_def_arn" {
  type = string
}

variable "DATADOG_API_KEY" {
  description = "Value of API key for the Datadog provider - PASSED TO API FOR SENDING CUSTOM EVENTS"
  type        = string
}

variable "DATADOG_APP_KEY" {
  description = "Value of app key for the Datadog provider - PASSED TO API FOR SENDING CUSTOM EVENTS"
  type        = string
}