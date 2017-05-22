#!/bin/bash

sed -i -E "s/^server-id=$/server-id=${BLACKFIRE_SERVER_ID}/g" /etc/blackfire/agent
sed -i -E "s/^server-token=$/server-token=${BLACKFIRE_SERVER_TOKEN}/g" /etc/blackfire/agent
sed -i -E "s/log-level=1/log-level=${BLACKFIRE_LOG_LEVEL}/g" /etc/blackfire/agent
/etc/init.d/blackfire-agent restart

/usr/local/bin/apache2-foreground
