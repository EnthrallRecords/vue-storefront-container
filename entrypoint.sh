#!/bin/sh
set -e

if [ "$VS_ENV" = 'dev' ]; then
  yarn dev
else
  yarn build:client && yarn build:server && yarn build:sw || exit $?
  yarn start
fi

#while true; do sleep 1000; done
/opt/vue-storefront/node_modules/pm2/bin/pm2 logs
