#!/bin/bash

if [ -z "$KNOWN_HOSTS_FILE" ]; then
    exec /usr/bin/ssh -i "$IDENT_KEY" "$@"
else
    exec /usr/bin/ssh -o UserKnownHostsFile="$KNOWN_HOSTS_FILE" -i "$IDENT_KEY" "$@"
fi
