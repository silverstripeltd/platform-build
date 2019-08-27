# Platform Build

Compacts a SilverStripe codebase into a deployable state with Composer and Node

## What is this?

This is a docker container that runs a series of commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
 - npm install + npm run scp-build (if the `scp-build` script is present) (will use Yarn instead if the codebase requires it)
 - composer run scp-build (if the `scp-build` script is present)

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
