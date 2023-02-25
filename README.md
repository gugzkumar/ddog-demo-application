# Datadog Demo Application

Website is hosted on: https://dev-ddog-demo.gugz.net/

<p align="left">
  <img
    src="docs/images/application-frontend.png"
    width="300"
  />
  <img
    src="docs/images/show-dashboard.png"
    width="400"
  />
</p>

The goal of this project is to showcase the integration of an application on AWS with Datadog. What is being built here is a simple web application, but is set up in a way that infrastructure resembles something closer to production.

The application itself is a REST api running on Nodejs in an ECS Cluster, and a react frontend hosted on S3 with a CloudFront distribution. The infrastructure is set up using Terraform, and the CI/CD is done using Github Actions.

The following is the application's architecture diagram with its core components:

<p align="left">
  <img
    src="docs/images/core-architecture.png"
    width="800"
  />
</p>

The following is the application's architecture diagram showing components integrated with Datadog:

<p align="left">
  <img
    src="docs/images/core-architecture-with-datadog.png"
    width="800"
  />
</p>

## Folder Structure
```
.github/workflows - Github Actions configurations for CI/CD of the API and Client code
.infrastructure   - Terraform configurations for infrastructure (AWS and Datadog)
    aws/          - Application's AWS infrastructure is here
    datadog/      - Datatog related infrastructure is here (ECS Agent Task Definition, Lambda Forwarder, AWS Integration, Dashboard)
api/              - Source code Node based REST API (express js)
client/           - Source code React based frontend
env.template      - Template for .env file used for local development
```

## Things I Should Add/Update to the Project
1. S3 bucket names should use the URL name, since this more unique, and will result in less conflicts especially if the same application is used by multiple people
2. Make sure to control the AWS IAM user's permissions to only allow the necessary permissions
3. Instructions to setting up different environments (dev, staging, prod)
    - I would use a different GitHub branch for every environment (dev, staging, prod)
    - I would use a different terraform workspace for every environment, where the VCS connection is set to the branch for that environment
    - This would involve some critical thinking especially at the enterprise scale
    - Parameterizing is not done everywhere yet
4. Instructions for adding Route 53 url and SSL certificate
