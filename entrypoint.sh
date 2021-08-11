#!/bin/sh
set -e

if [ "$VS_ENV" = 'dev' ]; then
  yarn dev
else
  yarn generate-files
  yarn build:sw
  yarn build:client
  yarn build:server
  ./node_modules/pm2/bin/pm2 delete all || true
  touch /root/.pm2/pm2.pid
  yarn start
fi
