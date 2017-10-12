#!/usr/bin/env bash
set -e

if [ ! -z "$@" ]; then
    exec "$@"
fi

set -x
composer validate
composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
/tmp/vendor/bin/vendor-plugin-helper copy ./
