FROM node:20-alpine

RUN mkdir -p ./usr/src/app/server

WORKDIR /usr/src/app/server

COPY ./app/server/package*.json .

RUN npm ci

COPY ./app/server .

# ARG SERVER_PORT
# ARG DATABASE_URL
# ENV SERVER_PORT=$SERVER_PORT
# ENV DATABASE_URL=$DATABASE_URL

EXPOSE 4000

CMD ["npm", "start"]