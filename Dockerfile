# Core tools / PHP extensions
FROM composer:2@sha256:e724f5bb40448f6548cc27706ec5b1e0494c10915b08d6141dce973483ae2611 AS composer
FROM php:7.4-cli@sha256:cbd8fd538f72258eb531ac9708d29a2b370c8ab933c9cc056e69100a93e01768

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
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh > install.sh

# Verify that the NVM installer remains uncompromised - bail on the build if not
ENV NVM_EXPECTED_HASH="9edb01eb5d3da634454ca8e02d4708f8  install.sh"
RUN if [ "`md5sum install.sh`" != "$NVM_EXPECTED_HASH" ]; then exit 1; fi;

# Install NVM without a default Node binary, add all LTS versions
ENV NODE_VERSION=
RUN bash install.sh
RUN . $NVM_DIR/nvm.sh && nvm install v6 && nvm install v8 && nvm install v10 && nvm install v12 && nvm install v14 && nvm install v16

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends yarn

COPY funcs.sh /funcs.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
