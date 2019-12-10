FROM node:10-buster@sha256:c5a1bf0d035d9eea4d1cae7099bb5e1089bf8a439c25d0f19d010e909e9d7407

RUN apt-get update && apt-get install -y curl php-cli git jq

# Allow uninhibited SSH connections to support fetching external resources
RUN mkdir -p ~/.ssh
RUN chmod 0700 ~/.ssh
RUN printf "Host *\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null\n" > ~/.ssh/config
RUN chmod 400 ~/.ssh/config

# Composer
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install legacy vendor-plugin-helper module as a fallback for exposing assets
RUN composer global require silverstripe/vendor-plugin-helper

# Fetch NVM installer and prep destination
ENV NVM_DIR=/root/.nvm
RUN mkdir -p /root/.nvm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh > install.sh

# Verify that the NVM installer remains uncompromised - bail on the build if not
ENV NVM_EXPECTED_HASH="d41d8cd98f00b204e9800998ecf8427e  -"
RUN if [ "`md5sum << install.sh`" != "$NVM_EXPECTED_HASH" ]; then exit 1; fi;

# Install NVM without a default Node binary, add 6 + 8 + 10 + 12
ENV NODE_VERSION=
RUN bash install.sh
RUN . $NVM_DIR/nvm.sh && nvm install v6 && nvm install v8 && nvm install v10 && nvm install v12

COPY funcs.sh /funcs.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]
