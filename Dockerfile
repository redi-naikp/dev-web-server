FROM docker-registry.rdti.com/com.redi.web/node:10.4.1

WORKDIR '/server-web'

COPY . .

RUN npm install
EXPOSE 8000

CMD ["node", "index.js"]