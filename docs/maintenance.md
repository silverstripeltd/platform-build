# Maintenance

## Updating the image

This Docker image depends on a set of base images for key requirements:

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

We use NVM for managing Node installation and selection, which is also pinned to
a specific release. You can update this by retrieving the current version of the
NVM installer, generating its MD5 hash, and updating the URL / hash in the
`Dockerfile`. NVM releases can be found [here](https://github.com/nvm-sh/nvm/releases).

Once you've updated the dependencies, build and test the new version, and then
tag and push it:

```
> docker build .
> docker tag silverstripe/platform-build:1.2.1 [built-hash]
> docker push silverstripe/platform-build:1.2.1
```

You can then update the tag in use via the Dash administration UI.

## Testing

This Docker image does not yet have an automated test harness, so adjustments
should be tested manually against the various permutations of project contents
that may be encountered:

- Silverstripe CMS 3 / 4.0 (old directory structure) / 4.3+
- Presence of cloud-build script in package.json / composer.json
- Use of Yarn vs NPM
- silverstripe/vendor-plugin version 1.x-dev / <1.4.1 / 1.4.1+
