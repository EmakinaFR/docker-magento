#!/bin/bash

if [[ -z ${ZEND_LICENSE_ORDER} || -z ${ZEND_LICENSE_KEY} ]]; then
    ZEND_LICENSE_ORDER=docker-zs
    ZEND_LICENSE_KEY=I2S87J41841G21E2B016CC232AA5A20F
fi

if [ -z ${ZS_ADMIN_PASSWORD} ]; then
    ZS_ADMIN_PASSWORD=`cat /root/zend-password 2> /dev/null`
    if [ -z ${ZS_ADMIN_PASSWORD} ]; then
        ZS_ADMIN_PASSWORD=`date +%s | sha256sum | base64 | head -c 8`
        echo ${ZS_ADMIN_PASSWORD} > /root/zend-password
    fi
fi

ZS_MANAGE=/usr/local/zend/bin/zs-manage
APP_UNIQUE_NAME=`hostname`
APP_IP=`/sbin/ifconfig eth0| grep 'inet addr:' | awk {'print $2'}| cut -d ':' -f 2`

usermod -a -G adm zend

service zend-server start
WEB_API_KEY=`cut -s -f 1 /root/api_key 2> /dev/null`
WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key 2> /dev/null`

if [ -z ${WEB_API_KEY} ]; then
    ${ZS_MANAGE} bootstrap-single-server -p ${ZS_ADMIN_PASSWORD} -r 'TRUE' -a 'TRUE' -o ${ZEND_LICENSE_ORDER} -l ${ZEND_LICENSE_KEY} | head -1 > /root/api_key
    WEB_API_KEY=`cut -s -f 1 /root/api_key`
    WEB_API_KEY_HASH=`cut -s -f 2 /root/api_key`
fi

${ZS_MANAGE} extension-on -e mongo -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}
${ZS_MANAGE} restart -p -N ${WEB_API_KEY} -K ${WEB_API_KEY_HASH}

echo ""
echo "Application => http://$APP_IP"
echo "Zend Server => http://$APP_IP:10081 (admin / $ZS_ADMIN_PASSWORD)"
echo ""
