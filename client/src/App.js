import './App.css';
import { Textarea, Button } from '@chakra-ui/react';
import { Tooltip } from '@chakra-ui/react';
import { Heading, Text } from '@chakra-ui/react';
import { Container } from '@chakra-ui/react';
import { Stack } from '@chakra-ui/react';
import axios from 'axios';
import { useState } from 'react';

const API_URL = process.env.REACT_APP_API_URL;

// Setup axios 
axios.defaults.baseURL = API_URL;

function App() {
  const [textAreaContent, setTextAreaContent] = useState('Results from button press will be displayed here');

  const handleResponse = (res) => {
    const responseAsString = JSON.stringify(res.data);
    console.log(responseAsString);
    setTextAreaContent(responseAsString);
  }
  const handleError = (err) => {
    console.error(err);
    setTextAreaContent('Something Went Wrong');
  }

  const testInfoLogsRequest = () => {
    axios.get('/info').then(handleResponse).catch(handleError);
  }
  
  const testErrorLogsRequest = () => {
    axios.get('/error').then(handleResponse).catch(handleError);
  }
  
  const testPushToS3Request = () => {
    axios.get('/pushtoS3').then(handleResponse).catch(handleError);
  }  

  return (
    <Container p={8}>
      <Stack spacing={4} direction='column' align={'center'}>
        <Heading>Datadog Demo Application</Heading>
        <Text color="gray">Author: Gagan Tunuguntla</Text>
        <Text align={'left'}>Each of the following buttons will help you see logs, events in Datadog</Text>
        <Tooltip openDelay={500} label="Clicking this will make the api service produce an info level log which you can see in Datadog">
          <Button colorScheme='blue' onClick={testInfoLogsRequest}>TEST INFO LOGS FOR DATADOG</Button>
        </Tooltip>
        <Tooltip openDelay={500} label="Clicking this will make the api service produce an error level log which you can see in Datadog">
          <Button colorScheme='red' onClick={testErrorLogsRequest}>TEST ERROR LOGS FOR DATADOG</Button>
        </Tooltip>
        <Tooltip openDelay={500} label="Clicking this will add data to the S3 datalake bucket, and trigger a custom event in Datadog">
          <Button colorScheme='orange' onClick={testPushToS3Request}>TEST ADDING DATA TO S3 AND SENDING AND EVENT TO DATADOG</Button>
        </Tooltip>
        <Textarea disabled value={textAreaContent}/>
      </Stack>
    </Container>
  );
}

export default App;
