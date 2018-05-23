#!/usr/bin/env bash
set -e

if [ ! -z "$@" ]; then
    exec "$@"
fi

export COMPOSER_PROCESS_TIMEOUT=1200

if [[ "z${IDENT_KEY}" == "z" ]]; then
    echo "No deploy key set"
else
    echo "Setting up deploy key"
    echo "${IDENT_KEY}" > ~/.ssh/id_rsa
    chmod 0600 ~/.ssh/id_rsa
fi

echo
echo composer validate
composer validate
echo
echo composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
echo
echo /tmp/vendor/bin/vendor-plugin-helper copy ./
/tmp/vendor/bin/vendor-plugin-helper copy ./
echo tar -czf /app.tar.gz .
tar -czf /app.tar.gz .

