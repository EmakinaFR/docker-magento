#!/bin/bash

function init_server()
{
    APP_IP="$(/sbin/ifconfig eth0| grep "inet addr:" | awk {"print $2"} | cut -d ":" -f 2)"
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

    service zend-server start
    WEB_API_KEY="$(cut -s -f 1 /root/api_key 2> /dev/null)"
    WEB_API_KEY_HASH="$(cut -s -f 2 /root/api_key 2> /dev/null)"

    if [[ -z "${WEB_API_KEY}" ]]; then
        "${ZS_MANAGE}" bootstrap-single-server -p "${ZS_ADMIN_PASSWORD}" -a "TRUE" \
            -o "${ZEND_LICENSE_ORDER}" -l "${ZEND_LICENSE_KEY}" | head -1 > /root/api_key

        WEB_API_KEY="$(cut -s -f 1 /root/api_key)"
        WEB_API_KEY_HASH="$(cut -s -f 2 /root/api_key)"
    fi
}

function init_configuration()
{
    sed -i -e "s|Listen 80|Listen 8080|g" /etc/apache2/ports.conf
    sed -i -e "s|:80|:8080|g" /etc/apache2/sites-enabled/000-default.conf
    sed -i -e "s|80.conf|8080.conf|g" /etc/apache2/sites-enabled/000-default.conf
    mv /usr/local/zend/etc/sites.d/zend-default-vhost-80.conf /usr/local/zend/etc/sites.d/zend-default-vhost-8080.conf
    mv /usr/local/zend/etc/sites.d/http/__default__/80 /usr/local/zend/etc/sites.d/http/__default__/8080

    "${ZS_MANAGE}" extension-on -e mongo -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}"
    "${ZS_MANAGE}" extension-off -e "Zend Debugger" -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}"
    "${ZS_MANAGE}" extension-off -e "Zend OPcache" -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}"
    "${ZS_MANAGE}" store-directive -d zray.enable -v 0 -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}"
}

function init_vhosts()
{
    SCRIPT_PATH="$(readlink -e "${0}")"
    DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

    VHOSTS_PATH="${DIRECTORY_PATH}/vhosts"
    if [[ -d "${VHOSTS_PATH}" ]]; then
        VHOST_FILES="$(find "${VHOSTS_PATH}" -maxdepth 1 -type f -name *:*)"
        if [[ ! -z "${VHOST_FILES}" ]]; then
            for FILE in ${VHOST_FILES}; do
                FILENAME="$(basename "${FILE}")"

                VHOST_NAME="$(echo "${FILENAME}" | cut -d : -f 1)"
                VHOST_PORT="$(echo "${FILENAME}" | cut -d : -f 2)"
                VHOST_CONTENT="$(< "${FILE}")"

                "${ZS_MANAGE}" vhost-add -n "${VHOST_NAME}" -p "${VHOST_PORT}" \
                    -t "$VHOST_CONTENT" -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}" 2>&1
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
    ZS_MANAGE=/usr/local/zend/bin/zs-manage

    init_server
    init_configuration
    init_vhosts
    "${ZS_MANAGE}" restart -N "${WEB_API_KEY}" -K "${WEB_API_KEY_HASH}"

    init_blackfire
    service zend-server restart

    touch "${LOCK_FILE}"
else
    service zend-server start
fi

tail -f /dev/null
