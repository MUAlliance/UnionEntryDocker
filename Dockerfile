FROM itzg/bungeecord

RUN apt install -y jq

ARG BUNGEE_HOME=/server
ENV FRP_HOME=/frp
ENV UNION_API_ROOT=https://skin.mualliance.ltd/api/union
ENV GITHUB_API_ROOT=https://github-api-bypass.sjmc.club

COPY --chmod=755 scripts/* /usr/bin
COPY --chmod=644 frp ${FRP_HOME}

RUN mkdir ${FRP_HOME}/conf-enabled
# Disable cache
ADD https://worldtimeapi.org/api/timezone/UTC /tmp/bustcache
RUN /usr/bin/download.sh

ENV TYPE=CUSTOM
ENV BUNGEE_JAR_FILE=/download/velocity.jar

ENV FRPS_BIND_PORT=7001
ENV FRPS_KCP_BIND_PORT=7002
ENV FRPS_QUIC_BIND_PORT=7003
ENV FRPS_WEBSERVER_PORT=7500

EXPOSE ${FRPS_BIND_PORT}/tcp ${FRPS_KCP_BIND_PORT}/udp ${FRPS_QUIC_BIND_PORT}/udp ${FRPS_WEBSERVER_PORT}

ENTRYPOINT ["/bin/bash", "-l", "-i", "/usr/bin/launch.sh"]
HEALTHCHECK --start-period=10s CMD /usr/bin/health.sh
