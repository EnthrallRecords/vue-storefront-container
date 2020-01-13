FROM node:13-alpine as build

ARG BRANCH

RUN apk add --no-cache git curl

RUN git clone --single-branch -b ${BRANCH} https://github.com/EnthrallRecords/vue-storefront.git /opt/vue-storefront \
    && cd /opt/vue-storefront \
    && yarn install \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json

FROM node:13-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

ENTRYPOINT "/entrypoint.sh"
