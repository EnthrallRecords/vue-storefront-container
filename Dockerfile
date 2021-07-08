FROM node:16-alpine as build

ARG BRANCH

RUN apk add --no-cache git curl build-base python3

COPY . /opt/vue-storefront

WORKDIR /opt/vue-storefront

RUN yarn install \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json

FROM node:16-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

ENTRYPOINT "/entrypoint.sh"
