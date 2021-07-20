FROM node:15-alpine as build

ARG BRANCH

RUN apk add --no-cache git curl build-base python2

COPY . /opt/vue-storefront

WORKDIR /opt/vue-storefront

RUN yarn install \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json

FROM node:15-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

RUN apk add --no-cache git && \
    npm install lerna && \
    apk del git

ENTRYPOINT "/entrypoint.sh"
