# ddog-demo-application
Trying to build a rough application that can help me learn some of Data Dog's features

## Prerequisites
- Terraform Enterprise
- AWS Account
- Datadog Account

## Folder Structure
```
.github/workflows - Github Actions configurations for CI/CD
.infrastructure   - Terraform configurations for infrastructure (AWS and Datadog)


```

## Setup of Data Dog to AWS


## Infrastructure Setup
1. Create a new AWS IAM user with programmatic access to setup the infrastructure

2. Go to your Terraform Enterprise instance and create a new workspace (using the GitHub VCS provider)
3. After setting up set the following variables:
    - `AWS_ACCESS_KEY_ID` - AWS Access Key ID for the IAM user
    - `AWS_SECRET_ACCESS_KEY` - AWS Secret Access Key for the IAM user
    - `AWS_DEFAULT_REGION` - AWS Region to deploy the infrastructure
    - `DD_API_KEY` - Datadog API Key
    - `DD_APP_KEY` - Datadog APP Key
3.

