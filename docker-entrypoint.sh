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

package_source ${SHA}
