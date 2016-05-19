#!/bin/bash

SCRIPT_PATH=$(readlink -f "$0")
DIRECTORY_PATH=$(dirname "${SCRIPT_PATH}")

function init_configuration()
{
    CONFIG_FILE="${DIRECTORY_PATH}/extra/my.cnf"
    if [[ -e "${CONFIG_FILE}" ]]; then
        cp -f "${CONFIG_FILE}" /etc/mysql/conf.d/custom.cnf
        echo "File \"${CONFIG_FILE}\" successfully imported."
    fi
}

function start_mysql()
{
    mysqld &
    PROCESS_ID=$!

    echo "Waiting MySQL..."

    until mysqladmin ping &> /dev/null; do
        sleep 1
    done

    echo "MySQL is alive."
}

function uncompress_files()
{
    cd "$1"

    for ZIP_FILE in $(ls *.zip 2>>/dev/null)
    do
        echo "Decompressing \"${ZIP_FILE}\"..."
        unzip "${ZIP_FILE}" && rm "${ZIP_FILE}"
        echo "File \"${ZIP_FILE}\" successfully decompressed."
    done

    for TGZ_FILE in $(ls *.tgz *.tar.gz 2>>/dev/null)
    do
        echo "Decompressing \"${TGZ_FILE}\"..."
        tar -xvf "${TGZ_FILE}" && rm "${TGZ_FILE}"
        echo "File \"${TGZ_FILE}\" successfully decompressed."
    done

    for GZ_FILE in $(ls *.gz 2>>/dev/null)
    do
        echo "Decompressing \"${GZ_FILE}\"..."
        gunzip "${GZ_FILE}" && "${GZ_FILE}"
        echo "File \"${GZ_FILE}\" successfully decompressed."
    done

    cd "${DIRECTORY_PATH}"
}

function init_databases()
{
    EXTRA_PATH="${DIRECTORY_PATH}/extra"
    if [[ -d "${EXTRA_PATH}" ]]; then
        uncompress_files "${EXTRA_PATH}"

        DATABASES_FILES="$(find "${EXTRA_PATH}" -maxdepth 1 -type f -name *.sql | sort)"
        if [[ ! -z "${DATABASES_FILES}" ]]; then
            for FILE in ${DATABASES_FILES}; do
                FILENAME="$(basename "${FILE}")"

                echo "Importing \"${FILE}\"..."
                IMPORT_OUTPUT="$(mysql -u root < "${FILE}" 2>&1)"

                if [[ ! -z "${IMPORT_OUTPUT}" ]]; then
                    echo "An error occured during the \"${FILENAME}\" import. ${IMPORT_OUTPUT}."
                else
                    echo "File \"${FILENAME}\" successfully imported."
                    rm "${FILE}"
                fi
            done
        fi
    fi
}

LOCK_FILE="/var/docker.lock"
if [[ ! -e "${LOCK_FILE}" ]]; then
    cp /entrypoint.sh /entrypoint-custom.sh
    sed -i -e "s|exec \"\$@\"|#exec \"\$@\"|g" /entrypoint-custom.sh
    /bin/bash /entrypoint-custom.sh mysqld

    init_configuration
    start_mysql
    init_databases

    touch "${LOCK_FILE}"
    wait "${PROCESS_ID}"
else
    /bin/bash /entrypoint.sh mysqld
fi
