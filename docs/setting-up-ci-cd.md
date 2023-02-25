# Setting Up Continuous Deployment Via GitHub Actions

Continuous Deployment automates the updating of new code in our Api and UI so that we can focus on building features rather than worrying about how to launch them. GitHub Actions is easy to use and free. It takes away the hassle of have to set up infrastructure for it.

The prerequisites for this guide is having went through the infrastructure setup guide and provisioning all of the resources.

**NOTE:** The project only has a dev environment setup, which is linked to the main branch. There is no staging or production environment setup.

## STEP 1: Add AWS Credentials

1. On your GitHub repo go to Settings > Secrets and variables > Actions
1. Add the following Repository secrets:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `AWS_DEFAULT_REGION`
1. Add the following Repository variables:
    - `CONTAINER_NAME`
    - `ECR_REPOSITORY`
    - `ECS_CLUSTER`
    - `ECS_SERVICE`
    - `ECS_TASK_DEFINITION`
    - `FRONTEND_S3_BUCKET`

## STEP 2: Commit and Push

1. Commit and push a slight change to your main branch
1. Go to Actions and you should see a workflow running with 2 actions
    - Deploy API to Amazon ECS
    - Deploy UI to Amazon S3
1. Once the workflow is complete, you should be able to see the changes on the website
