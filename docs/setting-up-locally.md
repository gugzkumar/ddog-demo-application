# Setting Up And Running The App On Your Local Machine

This guide is for you to have a working version of Datadog Demo running on your computer. This is useful for testing the app before you use it, and develop new features. All commands, unless otherwise noted, should be ran from the root project folder.

For this to work you will need docker and docker-compose installed on your computer, as well as an AWS account.

## STEP 1: Create a S3 bucket

Create an S3 bucket in AWS to represent the data lake.

## STEP 2: Grab Credentials

You will need the following credentials to run the app locally:

    - `AWS_ACCESS_KEY_ID` - AWS Access Key ID for the IAM user
    - `AWS_SECRET_ACCESS_KEY` - AWS Secret Access Key for the IAM user
    - `AWS_DEFAULT_REGION` - AWS Region of the data lake bucket
    - `DATADOG_API_KEY` - Datadog API Key
    - `DATADOG_APP_KEY` - Datadog APP Key

## STEP 3: Create a .env file

1. Create a file called `.env` in the root project folder by making a copy of `env.template`
1. Fill it with the credentials you got in the previous step, and the name of the S3 bucket you created in the first step

## STEP 4: Run the app

1. Now you have everything you need to run the app
1. Run `docker-compose up --build -d`
1. Wait for a minute or two after the command finishes running
1. You can now see the site on http://localhost:3000 :beers:
1. You can click on the buttons and see the text area change
1. If you click **TEST ADDING DATA TO S3 AND SENDING AND EVENT TO DATADOG**, you should see a new file in the S3 bucket and a new event in Datadog
1. Code changes you now make to the api and ui should happen real time
1. Run `docker-compose down -v` to take down the app
