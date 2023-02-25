/**
 * Simple API
 */
const winston = require('winston');
const express = require('express')
const cors = require('cors');
const AWS = require("aws-sdk");
const axios = require('axios');

const DD_EVENTS_URL = 'https://api.datadoghq.com/api/v1/events'
const { DATADOG_API_KEY, DATADOG_APP_KEY, S3_DATA_LAKE_BUCKET } = process.env;

const app = express()
const port = 4000

const logger = winston.createLogger({
    format: winston.format.json(),
    defaultMeta: { service: 'api-service' },
    transports: [new winston.transports.Console()]
});

app.use(cors())
app.use(express.json());

/**
 * Health Check Endpoint
 */
app.get('/', (req, res) => {
    return res.json({ 'message': 'API is healthy' })
})

/**
 * This endpoint is used to test the basic info level logging
 */
app.get('/info', (req, res) => {
    logger.info('TESTING THE LOGS!')
    return res.json({ 'message': 'TESTING THE LOGS!' })
})

/**
 * This endpoint is used to test the error logging
 */
app.get('/error', (req, res) => {
    logger.error('TESTING ERROR LOGS!')
    return res.json({ 'message': 'TESTING ERROR LOGS!' })
})

/**
 * This endpoint is used to test the ability to push an event to Datadog.
 * It also adds content to the S3 Data Lake, which can be then monitored by Datadog.
 */
app.get('/pushtoS3', async (req, res) => {
    const currentDate = new Date();
    const dateTimeString = currentDate.toISOString();
    const objectName = `ddog-demo-object-${dateTimeString}.json`;
    const objectData = '{ "message" : "This is a dummy object for demo purposes" }';
    const objectType = "application/json";
    const s3 = new AWS.S3();
    var successMessage = ""
    try {
        // setup params for putObject
        const params = {
            Bucket: S3_DATA_LAKE_BUCKET,
            Key: objectName,
            Body: objectData,
            ContentType: objectType,
        };
        successMessage = `File uploaded successfully at https://${S3_DATA_LAKE_BUCKET}.s3.amazonaws.com/${objectName}`
        const result = await s3.putObject(params).promise();
        logger.info(successMessage);
        await axios.post(DD_EVENTS_URL, {
            "title": `File uploaded to Datalake at ${currentDate.toDateString()}`,
            "text": successMessage,
            "priority": "normal",
            "source_type_name": "node",
            // Todo: Paramaterize the tags to be passed in from Environment Variables
            "tags": ["Environment:dev", "Application:ddog-demo", "service:ddog-demo-api"]
        }, {
            headers: {
                'Content-Type': 'application/json',
                'DD-API-KEY': DATADOG_API_KEY,
                'DD-APPLICATION-KEY': DATADOG_APP_KEY
            }
        })
        return res.json({ 'message': successMessage})
    } catch (error) {
        logger.error($`Failed to upload file ${objectName} to S3`);
        logger.error(JSON.stringify(error));
        return res.json({ 'message': `Failed to upload file ${objectName} to S3`})
    }
})

app.listen(port, () => logger.info(`Example app listening on port ${port}!`))
