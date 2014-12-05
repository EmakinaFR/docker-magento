#!/bin/bash

if [[ -z $ZEND_LICENSE_ORDER || -z $ZEND_LICENSE_KEY ]]; then
    ZEND_LICENSE_ORDER=docker-zs
    ZEND_LICENSE_KEY=LNUO7341801G21E2B0165435BC41FBDF
fi

if [ -z $ZS_ADMIN_PASSWORD ]; then
    ZS_ADMIN_PASSWORD=`date +%s | sha256sum | base64 | head -c 8`
    echo ${ZS_ADMIN_PASSWORD} > /root/zend-password
fi

ZS_MANAGE=/usr/local/zend/bin/zs-manage
HOSTNAME=`hostname`
APP_UNIQUE_NAME=$HOSTNAME
APP_IP=`/sbin/ifconfig eth0| grep 'inet addr:' | awk {'print $2'}| cut -d ':' -f 2`

service zend-server start
WEB_API_KEY=`cut -s -f 1 /root/api_key 2> /dev/null`
WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key 2> /dev/null`

if [ -z ${WEB_API_KEY} ]; then
    ${ZS_MANAGE} bootstrap-single-server -p ${ZS_ADMIN_PASSWORD} -a 'TRUE' -o ${ZEND_LICENSE_ORDER} -l ${ZEND_LICENSE_KEY} | head -1 > /root/api_key
    WEB_API_KEY=`cut -s -f 1 /root/api_key`
    WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key`
fi

${ZS_MANAGE} extension-on -e mongo -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}

echo ""
echo "Application => http://$APP_IP"
echo "Zend Server => http://$APP_IP:10081 (admin / $ZS_ADMIN_PASSWORD)"
echo ""
