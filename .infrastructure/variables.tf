variable "ENVIRONMENT" {
  description = "Environment name for the infrastructure you are setting up. Used for tagging and naming resources."
  type        = string
  default     = "dev"
}

variable "APPLICATION_NAME" {
  description = "Application name for the infrastructure you are setting up. Used for tagging and naming resources."
  type        = string
  default     = "ddog-demo"
}

variable "DATADOG_API_KEY" {
  description = "Value of API key for the Datadog provider"
  type        = string
}

variable "DATADOG_APP_KEY" {
  description = "Value of app key for the Datadog provider"
  type        = string
}

variable "AWS_ACCOUNT_ID" {
  description = "Your AWS Account ID without dashes"
  type        = string
}

variable "AWS_VPC_ID" {
  description = "The ID of the VPC to deploy the infrastructure into"
  type        = string
}

variable "AWS_SUBNETS" {
  description = "value of subnets to deploy the infrastructure into"
  type        = list(string)
}

variable "AWS_SECUTIRY_GROUP" {
  description = "value of security group to deploy the infrastructure into"
  type        = string
}