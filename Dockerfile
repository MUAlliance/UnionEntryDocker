FROM itzg/bungeecord

RUN apt install -y jq

ARG BUNGEE_HOME=/server
ENV FRP_HOME=/frp
ENV UNION_API_ROOT=https://skin.mualliance.ltd/api/union

COPY --chmod=755 scripts/* /usr/bin
COPY --chmod=644 frp ${FRP_HOME}

RUN /usr/bin/download.sh

ENV TYPE=CUSTOM
ENV BUNGEE_JAR_FILE=/download/velocity.jar

ENV FRPS_BIND_PORT=7001
ENV FRPS_KCP_BIND_PORT=7002
ENV FRPS_QUIC_BIND_PORT=7003
ENV FPRS_WEBSERVER_PORT=7500
ENV FRPS_WEBSERVER_ENABLED=false

EXPOSE ${FRPS_BIND_PORT} ${FRPS_KCP_BIND_PORT} ${FRPS_QUIC_BIND_PORT} ${FPRS_WEBSERVER_PORT}

ENTRYPOINT ["/bin/bash", "-l", "-i", "/usr/bin/launch.sh"]
HEALTHCHECK --start-period=10s CMD /usr/bin/health.sh