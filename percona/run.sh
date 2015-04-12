#!/bin/bash

function init_databases()
{
    SCRIPT_PATH=$(readlink -f "$0")
    DIRECTORY_PATH=$(dirname "$SCRIPT_PATH")

    DATABASES_PATH="$DIRECTORY_PATH/databases"
    if [ -d "$DATABASES_PATH" ]; then
        DATABASES_FILES="`find ${DATABASES_PATH} -maxdepth 1 -type f -name *.sql`"
        if [ ! -z "$DATABASES_FILES" ]; then
            for FILE in ${DATABASES_FILES}; do
                FILENAME=$(basename ${FILE})

                IMPORT_OUTPUT="$(mysql -u root < ${FILE} 2>&1)"
                if [ ! -z "$IMPORT_OUTPUT" ]; then
                    RESPONSE_CODE=1
                    echo "An error occured during the \"${FILENAME}\" import. ${IMPORT_OUTPUT}."
                fi
            done
        fi
    fi
}

LOCK_FILE="/var/docker.lock"
if [ ! -e ${LOCK_FILE} ]
then
    cp /docker-entrypoint.sh /docker-entrypoint-custom.sh
    sed -i -e 's|exec "$@"|echo $@ > /tmp/mysql_start|g' /docker-entrypoint-custom.sh
    /bin/bash /docker-entrypoint-custom.sh mysqld

    eval "`cat /tmp/mysql_start` &"
    PROCESS_ID=$!

    until mysqladmin ping &> /dev/null; do
        sleep 0.1
    done

    init_databases
    wait ${PROCESS_ID}
else
    /bin/bash /docker-entrypoint.sh mysqld
fi
