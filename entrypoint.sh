#!/bin/sh
set -e

yarn build || exit $?

if [ "$VS_ENV" = 'dev' ]; then
  yarn dev
else
  yarn start
fi

#while true; do sleep 1000; done
/opt/vue-storefront/node_modules/pm2/bin/pm2 logs
