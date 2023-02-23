# Variables setup for tagging and naming resources
locals {
  common_tags = {
    Application = var.APPLICATION_NAME
    Environment = var.ENVIRONMENT
  }
  aws_prefix = "${var.ENVIRONMENT}-${var.APPLICATION_NAME}"
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
  source         = "./datadog"
  common_tags    = local.common_tags
  aws_prefix     = local.aws_prefix
  AWS_ACCOUNT_ID = var.AWS_ACCOUNT_ID
  providers = {
    datadog = datadog
  }
}

module "aws_resources" {
  source         = "./aws"
  common_tags    = local.common_tags
  aws_prefix     = local.aws_prefix
  AWS_ACCOUNT_ID = var.AWS_ACCOUNT_ID
  AWS_VPC_ID     = var.AWS_VPC_ID
  AWS_SUBNETS    = var.AWS_SUBNETS
}
