# ddog-demo-application
Trying to build a rough application that can help me learn some of Data Dog's features

## Prerequisites
- Terraform Enterprise
- AWS Account
    - Create a new IAM user with programmatic access, and access keys
    - Instructions found here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
    - Instructions for creating Access Keys found here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
    - Note: Make sure to save the Access Key ID and Secret Access Key
- Datadog Account
    - Have an API Key and APP Key
    - Instructions found here: https://docs.datadoghq.com/account_management/api-app-keys/

## Folder Structure
```
.github/workflows - Github Actions configurations for CI/CD
.infrastructure   - Terraform configurations for infrastructure (AWS and Datadog)


```

## Setup of Data Dog to AWS


## Infrastructure Setup
1. Create a new AWS IAM user with programmatic access to setup the infrastructure
2. Go to your Terraform Enterprise instance and create a new workspace (using the GitHub VCS provider)
3. After setting up set the following variables (as variable category **Environment Variable**):
    - `AWS_ACCESS_KEY_ID` - AWS Access Key ID for the IAM user
    - `AWS_SECRET_ACCESS_KEY` - AWS Secret Access Key for the IAM user
    - `AWS_DEFAULT_REGION` - AWS Region to deploy the infrastructure
3. After setting up set the following variables (as variable category **Terraform Variable**):
    - `DATADOG_API_KEY` - Datadog API Key
    - `DATADOG_APP_KEY` - Datadog APP Key
    - `AWS_ACCOUNT_ID` - AWS Account ID without dashes
3. In settings, set the Terraform Working Directory to `./.infrastructure`
4. You should be able to run terraform plan from the workspace and see the resources that will be created
5. Run terraform apply to create the infrastructure
6. 
7. For reference this is where code from the terraform setup came from: https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/


## Things I Would Do in the Real World
1. Make sure to control the AWS IAM user's permissions to only allow the necessary permissions
2. Instructions to setting up different environments (dev, staging, prod)
    - I would use a different GitHub branch for every environment (dev, staging, prod)
    - I would use a different terraform workspace for every environment, where the VCS connection is set to the branch for that environment
    - This would involve some critical thinking especially at the enterprise scale
3. Local Development Setup
4. More pictures for better guided documentation d
1. SPLIT REPOS?
2. CI/CD of REPO
3. Hashicorp wrong account_id required: https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws