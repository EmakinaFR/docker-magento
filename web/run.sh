#!/bin/bash

SCRIPT_PATH="$(readlink -e "${0}")"
DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

function init_configuration()
{
    sed -i -e "s|Listen 80|Listen 8080|g" /etc/apache2/ports.conf
    sed -i -e "s|:80|:8080|g" /etc/apache2/sites-enabled/000-default.conf
    sed -i -e "s|80.conf|8080.conf|g" /etc/apache2/sites-enabled/000-default.conf
    mv /usr/local/zend/etc/sites.d/zend-default-vhost-80.conf /usr/local/zend/etc/sites.d/zend-default-vhost-8080.conf
    mv /usr/local/zend/etc/sites.d/http/__default__/80 /usr/local/zend/etc/sites.d/http/__default__/8080

    zs-manage extension-on -e mongo -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage extension-off -e "Zend Debugger" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage extension-off -e "Zend OPcache" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d zray.enable -v 0 -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
}

function init_vhosts()
{
    VHOSTS_PATH="${DIRECTORY_PATH}/extra"
    if [[ -d "${VHOSTS_PATH}" ]]; then
        VHOST_FILES="$(find "${VHOSTS_PATH}" -maxdepth 1 -type f -name *:* | sort)"
        if [[ ! -z "${VHOST_FILES}" ]]; then
            for FILE in ${VHOST_FILES}; do
                FILENAME="$(basename "${FILE}")"

                VHOST_NAME="$(echo "${FILENAME}" | cut -d : -f 1)"
                VHOST_PORT="$(echo "${FILENAME}" | cut -d : -f 2)"
                VHOST_CONTENT="$(< "${FILE}")"

                zs-manage vhost-add -n "${VHOST_NAME}" -p "${VHOST_PORT}" \
                    -t "$VHOST_CONTENT" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}" 2>&1
            done
        fi
    fi
}

function init_blackfire()
{
    read -r -d '' BLACKFIRE_INI <<HEREDOC
extension=blackfire.so
blackfire.agent_socket=tcp://blackfire:${BLACKFIRE_PORT}
blackfire.agent_timeout=5
blackfire.log_file=/var/log/blackfire.log
blackfire.log_level=${BLACKFIRE_LOG_LEVEL}
blackfire.server_id=${BLACKFIRE_SERVER_ID}
blackfire.server_token=${BLACKFIRE_SERVER_TOKEN}
HEREDOC

    echo "${BLACKFIRE_INI}" >> /usr/local/zend/etc/conf.d/blackfire.ini
}

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    sed -i -e "s|exec /usr/local/bin/nothing|#exec /usr/local/bin/nothing|g" /usr/local/bin/run
    /bin/bash /usr/local/bin/run
    php /usr/local/zs-init/waitTasksComplete.php

    WEB_API_KEY_NAME=`/usr/local/zs-init/stateValue.php WEB_API_KEY_NAME`
    WEB_API_KEY_HASH=`/usr/local/zs-init/stateValue.php WEB_API_KEY_HASH`

    init_configuration
    init_vhosts
    zs-manage restart -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"

    init_blackfire
    service zend-server restart

    touch "${LOCK_FILE}"
else
    service zend-server start
fi

HOSTS_FILE="${DIRECTORY_PATH}/extra/hosts"
if [[ -e "${HOSTS_FILE}" ]]; then
    cat "${HOSTS_FILE}" >> /etc/hosts
fi

tail -f /dev/null
