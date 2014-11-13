#!/bin/bash

ZS_MANAGE=/usr/local/zend/bin/zs-manage
WEB_API_KEY=`cut -s -f 1 /root/api_key 2> /dev/null`
WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key 2> /dev/null`

SCRIPT_PATH="`readlink -e $0`"
DIRECTORY_PATH="`dirname ${SCRIPT_PATH}`"

VHOSTS_PATH="$DIRECTORY_PATH/../vhosts"
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
            ${ZS_MANAGE} restart-php -p -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}
        fi
    fi
fi
