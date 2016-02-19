#!/bin/bash

SCRIPT_PATH="$(readlink -e "${0}")"
DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    cp /entrypoint.sh /entrypoint-custom.sh
    sed -i -e "s|exec \"\$@\"|#exec \"\$@\"|g" /entrypoint-custom.sh
    /bin/bash /entrypoint-custom.sh mongod

    CONFIG_FILE="${DIRECTORY_PATH}/extra/mongod.conf"
    if [[ -e "${CONFIG_FILE}" ]]; then
        cp "${CONFIG_FILE}" /etc/mongod.conf
    fi

    touch "${LOCK_FILE}"
fi

CONFIG_FILE="/etc/mongod.conf"
if [[ -e "${CONFIG_FILE}" ]]; then
    mongod -f "${CONFIG_FILE}"
else
    mongod
fi
