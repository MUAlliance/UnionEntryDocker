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

if [ ${FRP_WEBSERVER_ENABLED} ]; then
    ln -s ${FRP_HOME}/conf-enabled/frps-webserver.toml ${FRP_HOME}/conf-available/frps-webserver.toml
else 
    rm -f ${FRP_HOME}/conf-enabled/frps-webserver.toml
fi
exec ${FRP_HOME}/frps -c ${FRP_HOME}/frps-mua-entry-main.toml