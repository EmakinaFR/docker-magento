#!/bin/bash

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    touch "${LOCK_FILE}"
    # Install
    echo "Install";
    ln -s /usr/bin/nodejs /usr/local/bin/node;
    ln -s /usr/bin/npm /usr/local/bin/npm;
else
    # Start node js
    echo "Start node js";
    node -v
fi

tail -f /dev/null
