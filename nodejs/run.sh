#!/bin/bash

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

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    cp /docker-entrypoint.sh /docker-entrypoint-custom.sh
    sed -i -e "s|exec \"\$@\"|#exec \"\$@\"|g" /docker-entrypoint-custom.sh
    /bin/bash /docker-entrypoint-custom.sh mysqld

    init_configuration
    start_mysql
    init_databases
    touch "${LOCK_FILE}"
    wait "${PROCESS_ID}"
else
    /bin/bash /docker-entrypoint.sh mysqld
fi
