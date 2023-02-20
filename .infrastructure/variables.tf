variable "ENVIRONMENT" {
  description = "Environment name for the infrastructure you are setting up. Used for tagging resources."
  type        = string
  default     = "dev"
}

variable "APPLICATION_NAME" {
  description = "Application name for the infrastructure you are setting up. Used for tagging resources."
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
