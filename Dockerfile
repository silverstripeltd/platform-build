# Core tools / PHP extensions
FROM composer:2@sha256:d0b7feaff0e6c62cf280b5bc92927d645f5ada3e1d6dca6f9aa5e8b1d8b15649 AS composer
FROM php:7.4-cli@sha256:402da64d16c8a33103cf86d33b16a99d839afa4149cda5e08ed53dbcdc749e92

# Install core dependencies
RUN apt-get update && apt-get install -y curl git jq zip libzip-dev gnupg
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN pecl install zip && docker-php-ext-enable zip

# Pull Composer from base image
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Allow uninhibited SSH connections to support fetching external resources
RUN mkdir -p ~/.ssh
RUN chmod 0700 ~/.ssh
RUN printf "Host *\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null\n" > ~/.ssh/config
RUN chmod 400 ~/.ssh/config

# Install legacy vendor-plugin-helper module as a fallback for exposing assets
RUN composer global require silverstripe/vendor-plugin-helper

# Fetch NVM installer and prep destination
ENV NVM_DIR=/root/.nvm
RUN mkdir -p /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh > install.sh

# Verify that the NVM installer remains uncompromised - bail on the build if not
ENV NVM_EXPECTED_HASH="661c5958387130637da5b9c778dcc7b1  install.sh"
RUN if [ "`md5sum install.sh`" != "$NVM_EXPECTED_HASH" ]; then exit 1; fi;

# Install NVM without a default Node binary, add 6 + 8 + 10 + 12
ENV NODE_VERSION=
RUN bash install.sh
RUN . $NVM_DIR/nvm.sh && nvm install v6 && nvm install v8 && nvm install v10 && nvm install v12

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends yarn

COPY funcs.sh /funcs.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
