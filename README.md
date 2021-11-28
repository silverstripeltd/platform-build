# Platform Build

Transforms a Silverstripe CMS project into a deployable bundle using Composer
and related tools. This is primarily designed for use during deployments to
[Silverstripe Cloud](https://silverstripe.cloud).

## What is this?

This is a Docker container that runs three primary commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
 - composer vendor-expose copy

If present in the codebase, and CLOUD_BUILD_DISABLED env variable is not set, it will also run the following scripts:

 - npm/yarn run cloud-build (after running npm/yarn install)
 - composer run-script cloud-build

If PARSE_COMPOSER is set, the image will also run parse_composer.php script copied from CWP.

## Example usage / local debugging

You can run the container against a project locally to test or diagnose issues:

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

Creates a composer_cache volume if it doesn't exists and mounts that into the
Composer home folder `tmp`

`--volume ~/.ssh/id_rsa:/root/.ssh/id_rsa`

If your source code has private repositories, you will need to mount your
private key (deploy key) into the container (preferable as read only)

`--volume $PWD:/app`

The source code will be built from the `/app` directory inside the container, so
make sure you mount your source code into that.

## Maintenance

See [maintenance](docs/maintenance.md).
