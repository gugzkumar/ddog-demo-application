# ddog-demo-application

The goal of this project is to showcase the integration of an application on AWS with Datadog. What is being built here is a simple web application, but is set up in a way that infrastructure resembles something closer to production.

The application itself is a REST api running on Nodejs in an ECS Cluster, and a react frontend hosted on S3 with a CloudFront distribution. The infrastructure is set up using Terraform, and the CI/CD is done using Github Actions.

The following is the application's architecture diagram with its core components:

The following is the application's architecture diagram showing components integrated with Datadog:

<!-- ADD ARCHITECTURE DIAGRAM -->

## Folder Structure
```
.github/workflows - Github Actions configurations for CI/CD of the API and Client code
.infrastructure   - Terraform configurations for infrastructure (AWS and Datadog)
    datadog/      - Core datatog infrastructure is here
    aws/          - Rest of the AWS infrastructure is here
api/              - Source code Node based REST API (express js)
client/           - Source code React based frontend
```

# Setup

## Prerequisites
- Terraform Enterprise
- AWS Account
    - Create a new IAM user with programmatic access, and access keys
    - Instructions found here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
    - Instructions for creating Access Keys found here: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
    - Note: Make sure to save the Access Key ID and Secret Access Key
    - An AWS VPC ID you can deploy to
- Datadog Account
    - Have an API Key and APP Key
    - Instructions found here: https://docs.datadoghq.com/account_management/api-app-keys/

## Setup of Data Dog to AWS


### Infrastructure Setup
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
    - `AWS_VPC_ID` - AWS VPC ID
    - `AWS_PUBLIC_SUBNET_ID` - AWS Subnet ID
    - `AWS_PRIVATE_SUBNET_ID` - AWS Subnet ID
    - `ENVIRONMENT` - (optional) Environment name, can help with tagging, set to "dev" by default
    - `APPLICATION_NAME` - (optional) Application name, can help with tagging, set to "ddog-demo" by default
3. In settings, set the Terraform Working Directory to `./.infrastructure`
4. You should be able to run terraform plan from the workspace and see the resources that will be created
5. Run terraform apply to create the infrastructure
6. For reference this is where code from the terraform setup came from: https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/
7. You can see your resources in the aws console. The names start with `[ENVIRONMENT]-[APPLICATION_NAME]*`, example: `dev-ddog-demo-*`
8. You can also search for them in the AWS Resource Groups service using the tags Application:[APPLICATION_NAME] and Environment:[ENVIRONMENT].

### Manually Configure Datadog
1. Most things have been set up and integrated with Datadog, but there is one step that needs to be done manually. First look for the AWS Lambda function named `[ENVIRONMENT]-[APPLICATION_NAME]-datadog-forwarder`, and copy the ARN of the function.
2. Then go to the Datadog AWS Integrations page: https://app.datadoghq.com/integrations/amazon-web-services
3. Click on the AWS Account you want to configure, and go to the "Log Collection" tab
4. Copy and paste the ARN to "Log Autosubscription". Enable at the least the following Log Sources, since these are components in the application:
    - S3 Access Logs
    - Application ELB Access Logs
    - CloudFront Access Logs

### Uploading of the dashboard


## Things I Should Add to the Project
1. 
1. Make sure to control the AWS IAM user's permissions to only allow the necessary permissions
2. Instructions to setting up different environments (dev, staging, prod)
    - I would use a different GitHub branch for every environment (dev, staging, prod)
    - I would use a different terraform workspace for every environment, where the VCS connection is set to the branch for that environment
    - This would involve some critical thinking especially at the enterprise scale
3. Local Development Setup
4. More pictures for better guided documentation d
1. SPLIT REPOS?
2. CI/CD of REPO
4. Scope Restrictions?
5. Search all resources in the AWS Account
6. Supplemental instructions for debugging why something is not collected
7. Instructions for adding Route 53 url
