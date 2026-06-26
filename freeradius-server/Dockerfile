FROM freeradius/freeradius-server:3.2.10-alpine

LABEL org.opencontainers.image.authors="Ramon Gonçalves" \
    org.opencontainers.image.vendor="Ramon Gonçalves" \
    org.opencontainers.image.url="https://github.com/jytaloramon/docker-images" \
    org.opencontainers.image.documentation="https://github.com/jytaloramon/docker-images" \
    org.opencontainers.image.source="https://github.com/jytaloramon/docker-images.git" \
    org.opencontainers.image.title="FreeRADIUS Server" \
    org.opencontainers.image.version="3.2.10-1" \
    org.opencontainers.image.description="The most widely used RADIUS server in the world." 

ARG UID=1024
ARG GID=1024
ARG USER=freeradius
ARG GROUP=${USER}
ARG GECOS="FreeRADIUS"

ARG CONFIG_DIR=/etc/freeradius
ARG DATA_DIR=/var/lib/freeradius
ARG CACHE_DIR=/var/cache/freeradius
ARG LOG_DIR=/var/log/freeradius
ARG RUN_DIR=/run/freeradius

ENV PATH=/opt/sbin:/opt/bin:$PATH

WORKDIR /
USER root

COPY scripts/*.sh /

RUN apk add --no-cache perl \
    && addgroup -g ${GID} ${GROUP} \
    && adduser -u ${UID} -G ${GROUP} -g ${GECOS} -H -h ${DATA_DIR} -D -s /bin/sh ${USER} \
    && rm -rf /etc/raddb /opt/var/log/radius \
    && mv /opt/etc/raddb ${CONFIG_DIR} \
    && ln -sf ${CONFIG_DIR} /opt/etc/raddb \
    && ln -sf ${LOG_DIR} /opt/var/log/radius \
    && mkdir -m 750 ${DATA_DIR} ${CACHE_DIR} ${LOG_DIR} \
    && mkdir -m 755 ${RUN_DIR} \
    && chmod 750 ${CONFIG_DIR} \
    && chmod 755 /*.sh \
    && chown -R ${USER}:${GROUP} ${CONFIG_DIR} ${DATA_DIR} ${CACHE_DIR} ${LOG_DIR} ${RUN_DIR}

WORKDIR ${CONFIG_DIR}
USER ${USER}

EXPOSE 1812-1813/udp
EXPOSE 1812-1813/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ ]
