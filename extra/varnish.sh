#!/bin/bash

service zend-server stop
sed -i -e 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
sed -i -e 's/:80/:8080/g' /etc/apache2/sites-enabled/000-default.conf
sed -i -e 's/80.conf/8080.conf/g' /etc/apache2/sites-enabled/000-default.conf
mv /usr/local/zend/etc/sites.d/zend-default-vhost-80.conf /usr/local/zend/etc/sites.d/zend-default-vhost-8080.conf
mv /usr/local/zend/etc/sites.d/http/__default__/80 /usr/local/zend/etc/sites.d/http/__default__/8080
service zend-server start

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
DAEMON_OPTS="-a :80 \\
             -T localhost:6082 \\
             -f /etc/varnish/default.vcl \\
             -S /etc/varnish/secret \\
             -s malloc,256m \\
             -p cli_buffer=16384"
HEREDOC

sed -i -e "/# DAEMON_OPTS=\"\"/ {
   r ${VARNISH_TMP_FILE}
   d
   }" ${VARNISH_CONFIGURATION}
rm ${VARNISH_TMP_FILE}

service varnish start
