FROM node:dubnium-alpine3.10

RUN apk add --no-cache bash git python
RUN git clone https://github.com/waqas64/woc-explorer

COPY app.credentials.js /woc-explorer/app/credentials.js

RUN apk add make
RUN cd woc-explorer && \
  npm i && \
  npm run build

EXPOSE 3002

WORKDIR /woc-explorer
CMD npm run start