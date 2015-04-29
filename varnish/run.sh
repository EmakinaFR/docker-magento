#!/bin/bash

function init_configuration()
{
    VARNISH_CONFIGURATION='/etc/default/varnish'
    START_LINE=$(awk '/^DAEMON_OPTS="-a :6081 \\$/{ print NR; exit }' ${VARNISH_CONFIGURATION})
    if [[ "$START_LINE" =~ ^[0-9]+$ ]]; then
        END_LINE=$(wc -l < ${VARNISH_CONFIGURATION})
        for (( LINE_NUMBER = $START_LINE; LINE_NUMBER <= $END_LINE; LINE_NUMBER ++ ))
        do
            LINE_CONTENT=`sed ${LINE_NUMBER}'q;d' ${VARNISH_CONFIGURATION}`
            if [ "$LINE_CONTENT" == "" ]; then
                break
            fi

            NEW_LINE=$(echo "$LINE_CONTENT" | sed 's|\\|\\\\|g;s|"|\\"|g')
            sed -i -e "${LINE_NUMBER}s|.*|# $NEW_LINE|g" ${VARNISH_CONFIGURATION}
        done
    fi

    VARNISH_TMP_FILE='/tmp/varnish.conf'
    cat > ${VARNISH_TMP_FILE} <<HEREDOC
DAEMON_OPTS="-a :${VARNISH_PORT} \\
             -f /etc/varnish/default.vcl \\
             -T :${VARNISH_ADMIN_LISTEN_PORT} \\
             -S /etc/varnish/secret \\
             -s malloc,256m \\
             -p esi_syntax=0x2 \\
             -p cli_buffer=16384"
HEREDOC

    sed -i -e "/# DAEMON_OPTS=\"\"/ {
       r ${VARNISH_TMP_FILE}
       d
       }" ${VARNISH_CONFIGURATION}
    rm ${VARNISH_TMP_FILE}
}

function init_vcl()
{
    VARNISH_VCL='/etc/varnish/default.vcl'
    sed -i "s|\${VARNISH_BACKEND_IP}|${VARNISH_BACKEND_IP}|g" ${VARNISH_VCL}
    sed -i "s|\${VARNISH_BACKEND_PORT}|${VARNISH_BACKEND_PORT}|g" ${VARNISH_VCL}
}

LOCK_FILE="/var/docker.lock"
if [ ! -e ${LOCK_FILE} ]
then
    init_configuration
    init_vcl

    touch ${LOCK_FILE}
fi

service varnish start
varnishlog
