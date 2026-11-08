ARG BASE_IMAGE_VERSION="3.24.4"

FROM alpine:${BASE_IMAGE_VERSION}

ARG IMAGE_VERSION="2.6.15-1"

LABEL org.opencontainers.image.title="OpenLDAP" \
    org.opencontainers.image.version="${IMAGE_VERSION}" \
    org.opencontainers.image.description="An open source implementation of the Lightweight Directory Access Protocol (LDAP)." \ 
    org.opencontainers.image.authors="Ramon Gonçalves" \
    org.opencontainers.image.vendor="Ramon Gonçalves" \
    org.opencontainers.image.url="https://github.com/jytaloramon/docker-images" \
    org.opencontainers.image.documentation="https://github.com/jytaloramon/docker-images" \
    org.opencontainers.image.source="https://github.com/jytaloramon/docker-images.git"

ARG UID="1024"
ARG GID="1024"
ARG USER="openldap"
ARG GROUP="${USER}"
ARG GECOS="OpenLDAP"
ARG USER_SHELL="/bin/sh"
ARG USER_HOME="/nonexistent"

ARG CONFIG_DIR="/etc/openldap"
ARG DATA_DIR="/var/lib/openldap"
ARG CACHE_DIR="/var/cache/openldap"
ARG LOG_DIR="/var/log/openldap"
ARG RUN_DIR="/run/openldap"

USER root
WORKDIR /

COPY --chown=root:root scripts/*.sh /

RUN apk add --no-cache openldap \
    openldap-backend-all \
    openldap-overlay-all \
    openldap-passwd-argon2 \
    openldap-passwd-pbkdf2 \
    openldap-passwd-sha2 \
    openldap-clients \
    && deluser ldap \
    && addgroup -g ${GID} ${GROUP} \
    && adduser -u ${UID} -G ${GROUP} \
    -H -D -g "${GECOS}" -h ${USER_HOME} \
    -s ${USER_SHELL} ${USER} \
    && rm -rf ${CONFIG_DIR}/slapd.ldif \
    ${CONFIG_DIR}/slapd.conf \
    ${DATA_DIR}/openldap-data \
    && mkdir ${CACHE_DIR} ${LOG_DIR} \
    && chown -R ${USER}:${GROUP} \
    ${DATA_DIR} \
    ${CACHE_DIR} \
    ${LOG_DIR} \
    ${RUN_DIR} \
    && chmod -R 0700 ${DATA_DIR} ${CACHE_DIR} \
    && chmod -R 0750 ${LOG_DIR} ${RUN_DIR} \
    && chmod 755 /*.sh

USER ${USER}
WORKDIR ${CONFIG_DIR}

EXPOSE 389 636

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ ]
