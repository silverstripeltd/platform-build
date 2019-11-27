#!/usr/bin/env bash
set -e

source /funcs.sh

if [ -d ".git" ]; then
	SHA=$(git rev-parse HEAD)
else
	echo "Unable to determine SHA, failing."
	exit 1
fi

if [[ "z${IDENT_KEY}" == "z" ]]; then
	echo "No deploy key set"
else
	mkdir -p ~/.ssh
	echo "${IDENT_KEY}" > ~/.ssh/id_rsa
	chmod 0600 ~/.ssh/id_rsa
	FINGER_PRINT=$(ssh-keygen -E md5 -lf ~/.ssh/id_rsa | awk '{ print $2 }' | cut -c 5-)
	echo "Using deploy key ${FINGER_PRINT}"
fi

composer_install

# Run NPM/Yarn build script if the cloud-build command is defined
if [[ -f package.json && "`cat package.json | jq '.scripts["cloud-build"]?'`" != "null" ]]; then
	nvm_switch

	node_build
fi

# Run Composer build script if the cloud-build command is defined
if [[ -f composer.json && "`cat composer.json | jq '.scripts["cloud-build"]?'`" != "null" ]]; then
	composer_build
fi

if [[ -f vendor/silverstripe/vendor-plugin/composer.json ]]; then
	composer_vendor_expose
fi

package_source ${SHA}
