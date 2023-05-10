# Core tools / PHP extensions
FROM composer:2@sha256:6b8dbded0cfb109dd3b06902ba4b0406d9eda689ccce5363c46f8bf25451b083 AS composer
FROM php:8.2-cli@sha256:5d2d115e42afd2ac0c8373758221a6e942bac1d0f50d4928db6c6663d4d25981

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
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh > install.sh

# Verify that the NVM installer remains uncompromised - bail on the build if not
ENV NVM_EXPECTED_HASH="586d621487c98d7ae0b6f9727ec5bd84  install.sh"
RUN if [ "`md5sum install.sh`" != "$NVM_EXPECTED_HASH" ]; then exit 1; fi;

# Install NVM without a default Node binary, add all LTS versions
ENV NODE_VERSION=
RUN bash install.sh
RUN . $NVM_DIR/nvm.sh && nvm install v16 && nvm install v18 && nvm install v20

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends yarn

COPY funcs.sh /funcs.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
