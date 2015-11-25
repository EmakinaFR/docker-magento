#!/bin/bash

function init_server()
{
    APP_IP="$(/sbin/ifconfig eth0| grep "inet addr:" | awk {"print $2"} | cut -d ":" -f 2)"
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

    service apache2 start
}

function init_configuration()
{
    #sed -i -e "s|Listen 80|Listen 8080|g" /etc/apache2/ports.conf
    #sed -i -e "s|:80|:8080|g" /etc/apache2/sites-enabled/000-default.conf
    #sed -i -e "s|80.conf|8080.conf|g" /etc/apache2/sites-enabled/000-default.conf

    a2enmod ssl expires headers rewrite

    echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
}

function init_vhosts()
{
    echo "init_vhosts"
    SCRIPT_PATH="$(readlink -e "${0}")"
    DIRECTORY_PATH="$(dirname "${SCRIPT_PATH}")"

    VHOSTS_PATH="${DIRECTORY_PATH}/vhosts"
    echo "${VHOSTS_PATH}"
    if [[ -d "${VHOSTS_PATH}" ]]; then
        VHOST_FILES="$(find "${VHOSTS_PATH}" -maxdepth 1 -type f -name *.conf)"
        if [[ ! -z "${VHOST_FILES}" ]]; then
            for FILE in ${VHOST_FILES}; do
                FILENAME="$(basename "${FILE}")"

                VHOST_NAME="$(echo "${FILENAME}" | cut -d : -f 1)"
                VHOST_PORT="$(echo "${FILENAME}" | cut -d : -f 2)"
                VHOST_CONTENT="$(< "${FILE}")"

                echo "${VHOST_CONTENT}" > /etc/apache2/sites-available/${FILENAME}
                a2ensite "${VHOST_NAME}"
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

    echo "${BLACKFIRE_INI}" >> /etc/php5/cli/conf.d/blackfire.ini
}

function init_xdebug()
{
    read -r -d '' XDEBUG_INI <<HEREDOC
[xdebug]
xdebug.max_nesting_level=500
xdebug.profiler_enable_trigger=1
xdebug.profiler_output_dir=/var/www/html/xdebug
xdebug.profiler_output_name=cachegrind.out.%p.%u
xdebug.var_display_max_children=-1
xdebug.var_display_max_depth=-1
xdebug.var_display_max_data=-1
xdebug.remote_autostart=0
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_connect_back=1
xdebug.remote_handler=dbgp
HEREDOC

    echo "${XDEBUG_INI}" >> /etc/php5/apache2/conf.d/20-xdebug.ini

     read -r -d '' XDEBUG_PROFILE <<HEREDOC
# Xdebug
export PHP_IDE_CONFIG="serverName=Xdebug andromeda"
export XDEBUG_CONFIG="remote_host=$(echo $SSH_CLIENT | awk '{print $1}') idekey=PHPSTORM"
HEREDOC

    echo "${XDEBUG_PROFILE}" >> ~/.profile
}

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then

    init_server
    init_configuration
    init_vhosts
    init_xdebug
    init_blackfire

    service apache2 restart

    touch "${LOCK_FILE}"
else
    init_vhosts
    service apache2 start
fi

tail -f /dev/null
