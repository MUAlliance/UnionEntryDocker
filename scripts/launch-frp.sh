#!/bin/bash

port=8080
retries=10

opened="0"
for i in $(seq 1 ${retries}); do
    opened=`netstat -tunlp | grep ${port} | wc -l`
    if [ "${opened}" != "0" ]; then
        break
    fi
    sleep 5s
done

if [ "${opened}" = "0" ]; then
    echo "Velocity timed out."
    exit 1
else
    echo "Starting FRPS..."
fi

exec ${FRP_HOME}/frps -c ${FRP_HOME}/frps-mua-entry-main.toml