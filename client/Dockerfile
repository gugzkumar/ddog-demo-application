# Docker File that runs the react app in a container
FROM node:18.14.2-alpine
ENV HOME=/usr/src/app

WORKDIR $HOME
COPY ./package.json $HOME/
RUN npm install --quiet
COPY . $HOME

# Commnand that starts react app
CMD npm start
