#!/bin/bash

SCRIPT_PATH="$(readlink -e "${0}")"
DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

function init_vhosts()
{
    VHOSTS_PATH="${DIRECTORY_PATH}/extra"
    if [[ -d "${VHOSTS_PATH}" ]]; then
        VHOST_FILES="$(find "${VHOSTS_PATH}" -maxdepth 1 -type f -name *.dev | sort)"
        if [[ ! -z "${VHOST_FILES}" ]]; then
            for FILE in ${VHOST_FILES}; do
                zs-manage vhost-add -n "$(basename "${FILE}")" -p "${ZEND_SERVER_PORT}" \
                    -t "$(< "${FILE}")" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}" 2>&1
            done
        fi
    fi
}


LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    sed -i -e "s|exec /usr/local/bin/nothing|#exec /usr/local/bin/nothing|g" /usr/local/bin/run
    /bin/bash /usr/local/bin/run
    php /usr/local/zs-init/waitTasksComplete.php

    WEB_API_KEY_NAME=`/usr/local/zs-init/stateValue.php WEB_API_KEY_NAME`
    WEB_API_KEY_HASH=`/usr/local/zs-init/stateValue.php WEB_API_KEY_HASH`

    zs-manage extension-on -e mongo -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d zray.enable -v 0 -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"

    init_vhosts
    zs-manage restart -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"

    touch "${LOCK_FILE}"
else
    service zend-server start
fi

HOSTS_FILE="${DIRECTORY_PATH}/extra/hosts"
if [[ -e "${HOSTS_FILE}" ]]; then
    cat "${HOSTS_FILE}" >> /etc/hosts
fi

tail -f /dev/null
