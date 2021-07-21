#!/bin/sh
set -e

if [ "$VS_ENV" = 'dev' ]; then
  yarn dev
else
  yarn build:client && yarn build:server && yarn build:sw || exit $?
  yarn start
fi
