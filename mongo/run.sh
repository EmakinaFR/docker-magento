#!/bin/bash

cp /entrypoint.sh /entrypoint-custom.sh
sed -i -e 's|exec "$@"|echo $@ > /tmp/mongod_start|g' /entrypoint-custom.sh
/bin/bash /entrypoint-custom.sh mongod

eval "`cat /tmp/mongod_start` --fork --smallfiles --logpath /var/log/mongodb.log"
PROCESS_ID=$!

wait ${PROCESS_ID}
