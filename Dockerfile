FROM node:10-alpine as build

ARG BRANCH

RUN apk add --no-cache git curl

RUN git clone --single-branch -b ${BRANCH} https://github.com/EnthrallRecords/vue-storefront.git /opt/vue-storefront \
    && cd /opt/vue-storefront \
    && yarn install \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json

FROM node:10-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY vsf-external-checkout.js /opt/vue-storefront/node_modules/vsf-external-checkout/index.js
COPY extensions.js /opt/vue-storefront/src/extensions/index.ts

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

ENTRYPOINT "/entrypoint.sh"
