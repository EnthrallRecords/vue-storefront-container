FROM node:10-alpine as build

RUN apk add --no-cache git curl

RUN git clone https://github.com/DivanteLtd/vue-storefront.git /opt/vue-storefront \
    && cd /opt/vue-storefront \
    && yarn install \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json \
    && yarn build

FROM node:10-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

ENTRYPOINT "/entrypoint.sh"
