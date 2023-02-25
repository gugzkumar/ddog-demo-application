const winston = require('winston');
const express = require('express')
const app = express()
const port = 4000

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    defaultMeta: { service: 'user-service' },
    transports: [
        //
        // - Write all logs with importance level of `error` or less to `error.log`
        // - Write all logs with importance level of `info` or less to `combined.log`
        //
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' }),
    ],
});
logger.add(new winston.transports.Console({
    format: winston.format.simple(),
}));

app.get('/', (req, res) => {
    logger.info('TESTING THE LOGS!')
    return res.send('TESTING THE LOGS!')
})

app.get('/error', (req, res) => {
    logger.error('TESTING THE ERROR LOGS!')
    logger.info('TESTING THE ERROR LOGS!')
    return res.send('TESTING THE ERROR LOGS!')
})

app.listen(port, () => logger.info(`Example app listening on port ${port}!`))
