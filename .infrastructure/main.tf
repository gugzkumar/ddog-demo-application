locals {
  common_tags = {
    Terraform = "true"
    Application = var.APPLICATION
    Environment = var.ENVIRONMENT
  }
}

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.DATADOG_API_KEY
  app_key = var.DATADOG_APP_KEY
}

# Configure the AWS provider (access should be configured via environment variables):
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - AWS_DEFAULT_REGION
provider "aws" {}

# Modules
module "datadog_apm" {
  source = "./modules/datadog-apm"
  common_tags = local.common_tags
}