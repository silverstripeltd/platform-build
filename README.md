# Platform Build

Compacts a Silverstripe CMS project into a deployable bundle using Composer and related tools.

## What is this?

This is a Docker container that runs three primary commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
 - composer vendor-expose copy

If present in the codebase, it will also run the following scripts:

 - npm/yarn run cloud-build (after running npm/yarn install)
 - composer run-script cloud-build

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

`--volume composer_cache:/tmp/cache`

Creates a composer_cache volume if it doesn't exists and mounts that into the composer home folder `tmp`

`--volume ~/.ssh/id_rsa:/root/.ssh/id_rsa`

If your source code has private repositories, you will need to mount the private key (deploy key) into the container (preferable as read only)

`--volume $PWD:/app`

The source code will be build from the `/app` 'inside' the container, so make sure you mount source code into that

## Updating base images

This docker image depends on a set of base images for key requirements:

- composer:1
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
- silverstripe/vendor-plugin version 1.x-dev / <1.4.1 / 1.4.1+
