FROM node:12.7.0-alpine

WORKDIR '/server-web'

COPY . .

RUN npm install
EXPOSE 8000

CMD ["node", "index.js"]