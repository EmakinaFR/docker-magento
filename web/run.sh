#!/bin/bash

function init_port()
{
    sed -i -e 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
    sed -i -e 's/:80/:8080/g' /etc/apache2/sites-enabled/000-default.conf
    sed -i -e 's/80.conf/8080.conf/g' /etc/apache2/sites-enabled/000-default.conf
    mv /usr/local/zend/etc/sites.d/zend-default-vhost-80.conf /usr/local/zend/etc/sites.d/zend-default-vhost-8080.conf
    mv /usr/local/zend/etc/sites.d/http/__default__/80 /usr/local/zend/etc/sites.d/http/__default__/8080
}

function init_configuration()
{
    ${ZS_MANAGE} store-directive -d zray.enable -v 0 -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}
    ${ZS_MANAGE} extension-on -e mongo -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}
}

function init_vhosts()
{
    SCRIPT_PATH="`readlink -e $0`"
    DIRECTORY_PATH="`dirname ${SCRIPT_PATH}`"

    VHOSTS_PATH="$DIRECTORY_PATH/vhosts"
    if [ -d "$VHOSTS_PATH" ]; then
        VHOST_FILES="`find ${VHOSTS_PATH} -maxdepth 1 -type f -name *:*`"
        if [ ! -z "$VHOST_FILES" ]; then
            NEW_VHOSTS=''

            for FILE in ${VHOST_FILES}; do
                FILENAME=$(basename ${FILE})

                VHOST_NAME="`echo ${FILENAME} | cut -d : -f 1`"
                VHOST_PORT="`echo ${FILENAME} | cut -d : -f 2`"
                CREATION_OUTPUT="$(${ZS_MANAGE} vhost-add -n ${VHOST_NAME} -p ${VHOST_PORT} -t "$(< ${FILE})" -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH} 2>&1)"

                VHOST_ID="`echo ${CREATION_OUTPUT} | cut -d ' ' -f 2`"
                if [[ "$VHOST_ID" =~ ^[0-9]+$ ]]; then
                    NEW_VHOSTS="$NEW_VHOSTS $VHOST_NAME"
                fi
            done

            if [ -n "$NEW_VHOSTS" ]; then
                echo "127.0.0.1 $NEW_VHOSTS" >> /etc/hosts
            fi
        fi
    fi
}

LOCK_FILE="/var/docker.lock"
if [ ! -e ${LOCK_FILE} ]
then
    sed -i -e 's|exec /usr/local/bin/nothing|#exec /usr/local/bin/nothing|g' /usr/local/bin/run
    /bin/bash /usr/local/bin/run

    ZS_MANAGE=/usr/local/zend/bin/zs-manage
    WEB_API_KEY=`cut -s -f 1 /root/api_key 2> /dev/null`
    WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key 2> /dev/null`

    init_port
    init_configuration
    init_vhosts

    ${ZS_MANAGE} restart-php -p -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}
    touch ${LOCK_FILE}
else
    service zend-server start
fi

exec /usr/local/bin/nothing
