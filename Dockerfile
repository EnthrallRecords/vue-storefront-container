FROM proxy.containers.internal/library/node:15-alpine as build

ARG STOREFRONT_VERSION=v1.12.3

RUN apk add --no-cache git curl build-base python2 && \
    npm install -g npm

RUN git clone -b $STOREFRONT_VERSION https://github.com/vuestorefront/vue-storefront.git /opt/vue-storefront

WORKDIR /opt/vue-storefront

RUN npm install -g lerna \
    && cp /opt/vue-storefront/config/default.json /opt/vue-storefront/config/local.json \
    && git submodule add -b master https://github.com/vuestorefront/vsf-default.git src/themes/default \
    && git submodule add -b master https://github.com/DivanteLtd/vsf-capybara.git src/themes/capybara \
    && git submodule update --init --remote

RUN lerna bootstrap

RUN lerna add @storefront-ui/vue@0.10.8 \
    && lerna add @storefront-ui/shared@0.10.8

RUN npx browserslist@latest --update-db

FROM proxy.containers.internal/library/node:15-alpine

COPY --from=0 /opt/vue-storefront /opt/vue-storefront

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront

ENTRYPOINT "/entrypoint.sh"
