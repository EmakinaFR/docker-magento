#!/bin/bash

service mysql start

SCRIPT_PATH="`readlink -e $0`"
DIRECTORY_PATH="`dirname ${SCRIPT_PATH}`"
RESPONSE_CODE=0

DATABASES_PATH="$DIRECTORY_PATH/../databases"
if [ -d "$DATABASES_PATH" ]; then
    DATABASES_FILES="`find ${DATABASES_PATH} -maxdepth 1 -type f -name *.sql`"
    if [ ! -z "$DATABASES_FILES" ]; then
        for FILE in ${DATABASES_FILES}; do
            FILENAME=$(basename ${FILE})

            IMPORT_OUTPUT="$(mysql -h localhost < ${FILE} 2>&1)"
            if [ ! -z "$IMPORT_OUTPUT" ]; then
                RESPONSE_CODE=1
                echo "An error occured during the \"${FILENAME}\" import. ${IMPORT_OUTPUT}."
            fi
        done
    fi
fi

mongod --fork --smallfiles --logpath /var/log/mongodb.log

exit ${RESPONSE_CODE}
