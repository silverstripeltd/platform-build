# Core tools / PHP extensions
FROM composer:1@sha256:010326d7c2096c956b29edc175f656fedaf41a65d1f4da3e93c42b1118b27b90 AS composer
FROM php:7.3-cli@sha256:a4f7d5f3887638eb29b220e50e0ebba2fde3c4a7c764b58d5ff826ced8cc7dac

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
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh > install.sh

# Verify that the NVM installer remains uncompromised - bail on the build if not
ENV NVM_EXPECTED_HASH="fbd8e6289e6e83d0809ef96bf73cd699  install.sh"
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
