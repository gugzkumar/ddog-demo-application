# Setup Datadog Forwarder to ship logs from AWS resources to Datadog
# https://docs.datadoghq.com/logs/guide/forwarder/#terraform
#
# Note, while this enables Datadog to collect logs from AWS resources,
# it does not enable Datadog to collect logs from ECS containers.
# Also to enable the forwarder to collect logs from the resources
# you need to set the Fowarder Lambda function's ARN on the Datadog website
# after the forwarder is provisioned.

# Store Datadog API key in AWS Secrets Manager
resource "aws_secretsmanager_secret" "dd_api_key" {
  name        = "datadog_api_key"
  description = "Encrypted Datadog API Key"
}

resource "aws_secretsmanager_secret_version" "dd_api_key" {
  secret_id     = aws_secretsmanager_secret.dd_api_key.id
  secret_string = var.DATADOG_API_KEY
}

output "dd_api_key" {
  value = aws_secretsmanager_secret.dd_api_key.arn
}

# Datadog Forwarder to ship logs from S3 and CloudWatch, as well as observability data from Lambda functions to Datadog.
# https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring
resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters   = {
    DdApiKeySecretArn  = aws_secretsmanager_secret.dd_api_key.arn
    DdSite             = "datadoghq.com",
    FunctionName       = "${var.aws_prefix}-datadog-forwarder"
    DdTags             = "Environment:${var.common_tags.Environment},Application:${var.common_tags.Application}"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}
