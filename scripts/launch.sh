#!/bin/bash

echo "================================================"
echo "         Starting MUA Union Lobby Entry         "
echo "================================================"

function launch() {
    rm -f /server/authlib-injector.jar
    cp /download/authlib-injector.jar /server
    union_plugins="/download/ProxiedProxy.jar,/download/mua-proxy-plugin.jar,/download/UnionSyncAnnouncement.jar"
    if [ ! ${DISABLE_PLUGIN_MAPMODCOMPANION} ] ; then
        union_plugins="${union_plugins},/download/MapModCompanion.jar"
        exit 1
    fi
    if [ ! ${DISABLE_PLUGIN_MAPPEDDIMENSIONNAME} ] ; then
        union_plugins="${union_plugins},/download/protocolize.jar,/download/MappedDimensionName.jar"
        exit 1
    fi
    JVM_OPTS="${JVM_OPTS} -javaagent:/server/authlib-injector.jar=${UNION_API_ROOT}/yggdrasil" \
    PLUGINS="${PLUGINS},${union_plugins}" \
    /usr/bin/run-bungeecord.sh
}

function first_launch_setup() {
    if [ ! ${UNION_ENTRY_ID} ] ; then
        echo "Please set environment variable UNION_ENTRY_ID."
        exit 1
    fi
    if [ ! ${FRPS_AUTH_TOKEN} ] ; then
        echo "Please set environment variable FRPS_AUTH_TOKEN."
        exit 1
    fi
    if [ ! ${UNION_SYNC_URL} ] ; then
        echo "Please set environment variable UNION_SYNC_URL."
        exit 1
    fi
    if [ ! ${UNION_SYNC_AUTH_TOKEN} ] ; then
        echo "Please set environment variable UNION_SYNC_AUTH_TOKEN."
        exit 1
    fi
    if [ ! ${UNION_SYNC_AUTH_ID} ] ; then
        echo "Using ${UNION_ENTRY_ID} as UNION_SYNC_AUTH_ID."
        UNION_SYNC_AUTH_ID=${UNION_ENTRY_ID}
    fi


    echo "Generating configurations..."

    launch <<< "end" > /dev/null
    
    echo "Setting configurations..."

    cp /server/plugins/proxied-proxy/config-template-entry.toml /server/plugins/proxied-proxy/config.toml
    # Change forwarding to legacy
    sed -i 's/player-info-forwarding-mode = "\(.*\)"/player-info-forwarding-mode = "legacy" # Automatically set on first launch/i;
            s/ping-passthrough = "\(.*\)"/ping-passthrough = "all" # Automatically set on first launch/i' /server/velocity.toml
    # Set ProxiedProxy config
    sed -i 's/entry-id = "\(.*\)"/entry-id = "'"${UNION_ENTRY_ID}"'" # Automatically set on first launch/i' /server/plugins/proxied-proxy/config.toml
    # Set UnionSync config
    sed -i 's|server = "\(.*\)"|server = "'"${UNION_SYNC_URL}"'" # Automatically set on first launch|i;
            s|type = "\(.*\)"|type = "UNION" # Automatically set on first launch|i;
            s|id = "\(.*\)"|id = "'"${UNION_SYNC_AUTH_ID}"':entry" # Automatically set on first launch|i;
            s|token = "\(.*\)"|token = "'"${UNION_SYNC_AUTH_TOKEN}"'" # Automatically set on first launch|i' /server/plugins/union-sync/config.toml

    launch <<< "end" > /dev/null

    mkdir /server/union
    cp /server/plugins/proxied-proxy/entry.json /server/union
    cat > /server/union/frpc.txt <<-EOF
id = ${UNION_ENTRY_ID}
bindPort = ${FRPS_BIND_PORT}
kcpBindPort = ${FRPS_KCP_BIND_PORT}
quicBindPort = ${FRPS_QUIC_BIND_PORT}
token = ${FRPS_AUTH_TOKEN}
EOF

}

if [ -f "/server/union/entry.json" ]; then
    /usr/bin/launch-frp.sh > /server/frps.log &
    pid2=$!

    launch

    kill -9 $pid2
else
    first_launch_setup
    echo "Successfully configured Union Entry! Please check /server/union for more details."
    echo "You may edit configurations and start the server again."
    echo "Please also edit the default lobby server in velocity.toml."
fi
