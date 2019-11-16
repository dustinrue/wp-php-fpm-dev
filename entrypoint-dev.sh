#!/bin/bash

ENABLE_XDEBUG=$(echo ${ENABLE_XDEBUG:-false} | tr '[:upper:]' '[:lower:]')

if [ ${ENABLE_XDEBUG} == true ]; then
  ln -fs /etc/php-extensions-available/15-xdebug.ini /etc/php.d/15-xdebug.ini
else
  rm -f /etc/php.d/15-xdebug.ini
fi

exec /entrypoint.sh
