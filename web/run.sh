#!/bin/bash

SCRIPT_PATH="$(readlink -e "${0}")"
DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

function bootstrap_server()
{
    sed -i -e "s|exec /usr/local/bin/nothing|#exec /usr/local/bin/nothing|g" /usr/local/bin/run
    /bin/bash /usr/local/bin/run
    php /usr/local/zs-init/waitTasksComplete.php

    WEB_API_KEY_NAME=`/usr/local/zs-init/stateValue.php WEB_API_KEY_NAME`
    WEB_API_KEY_HASH=`/usr/local/zs-init/stateValue.php WEB_API_KEY_HASH`

    zs-manage extension-on -e mongo -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d zray.enable -v 0 -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d SMTP -v mailcatcher -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d smtp_port -v 1025 -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d sendmail_path -v "/usr/sbin/ssmtp -t" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    zs-manage store-directive -d date.timezone -v "Europe/Paris" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"

    echo >> /etc/apache2/apache2.conf
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

    touch "${LOCK_FILE}"
}

function init_vhosts()
{
    WEB_API_KEY_NAME=`/usr/local/zs-init/stateValue.php WEB_API_KEY_NAME`
    WEB_API_KEY_HASH=`/usr/local/zs-init/stateValue.php WEB_API_KEY_HASH`

    VHOSTS_PATH="/tmp/vhosts"
    if [[ -d "${VHOSTS_PATH}" ]]; then
        VHOST_FILES="$(find "${VHOSTS_PATH}" -maxdepth 1 -type f -name *.dev | sort)"
        if [[ ! -z "${VHOST_FILES}" ]]; then
        CURRENT_VHOSTS="$(zs-manage vhost-get-status -N ${WEB_API_KEY_NAME} -K ${WEB_API_KEY_HASH} | awk -F '\t' '{print $3}')"

            for FILE in ${VHOST_FILES}; do
                VHOST_NAME="$(basename "${FILE}")"
                echo "${CURRENT_VHOSTS}" | grep -q "${VHOST_NAME}"

                if [[ $? -ne 0 ]]; then
                    zs-manage vhost-add -n "${VHOST_NAME}" -p 80 \
                        -t "$(< "${FILE}")" -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}" 2>&1
                fi
            done
        fi

        zs-manage restart -N "${WEB_API_KEY_NAME}" -K "${WEB_API_KEY_HASH}"
    fi
}

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    bootstrap_server
fi

service zend-server start
init_vhosts

tail -f /dev/null
