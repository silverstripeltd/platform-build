# Platform Build

Compacts a Silverstripe CMS project into a deployable bundle using Composer and related tools.

## What is this?

This is a Docker container that runs three primary commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest --no-scripts
 - composer vendor-expose copy

If present in the codebase, it will also run the following scripts:

 - npm/yarn run cloud-build (after running npm/yarn install)
 - composer run-script cloud-build

Composer scripts can be enabled during the install process by adding the following configuration to your `.platform.yml` file:

```yml
build:
  composer_scripts: true
```

## Example usage

```
docker run \
    --interactive \
    --tty \
    --volume composer_cache:/tmp/cache \
    --volume ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
    --volume $PWD:/app \
    silverstripe/platform-build
```

### composer_cache

`--volume composer_cache:/tmp/cache`

Creates a composer_cache volume if it doesn't exists and mounts that into the composer home folder `tmp`

### SSH credentials for private repo access

`--volume ~/.ssh/id_rsa:/root/.ssh/id_rsa`

If your source code has private repositories, you will need to mount the private key (deploy key) into the container (preferable as read only)

if you are developing locally there is a good chance your private key has a passphrase or some other setup which might mean it is easier to use ssh agent forwarding. For example:

```
--volume $SSH_AUTH_SOCK:/ssh-agent \
--env SSH_AUTH_SOCK=/ssh-agent \
```
on mac there is a different path setting see:  https://docs.docker.com/docker-for-mac/osxfs/#ssh-agent-forwarding

### Source code directory

`--volume $PWD:/app`

The source code will be build from the `/app` 'inside' the container, so make sure you mount source code into that

## Updating base images

This docker image depends on a set of base images for key requirements:

- composer:1
- mikefarah/yq:3
- php:7.3-cli

We lock these to explicit releases via their hash, to reduce the risk of pulling
in unwanted changes when rebuilding the image, but it's important to update
these from time to time. You can do this by replacing the hash with the latest
version, either by looking it up in Docker Hub or by running the following
commands:

```
> docker pull composer:1
> docker images --no-trunc --quiet composer:1
```

## Testing

This Docker image does not yet have an automated test harness, so adjustments should be tested manually against the various permutations of project contents that may be encountered:

- Silverstripe CMS 3 / 4.0 (old directory structure) / 4.3+
- Presence of cloud-build script in package.json / composer.json
- Use of Yarn vs NPM
- Composer scripts enabled / disabled via .platform.yml
- silverstripe/vendor-plugin version 1.x-dev / <1.4.1 / 1.4.1+
