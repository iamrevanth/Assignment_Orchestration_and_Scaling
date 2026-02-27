# Use a smaller base image
FROM node:16-alpine

# Working directory be app
WORKDIR /usr/src/app

COPY package*.json ./

###  Installing dependencies

RUN npm install --force --no-audit --loglevel=error

# copy local files to app folder
COPY . .

EXPOSE 3000

CMD ["npm","start"]
