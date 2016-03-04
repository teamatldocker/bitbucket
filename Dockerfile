FROM blacklabelops/java:openjre8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ARG BITBUCKET_VERSION=4.4.1
# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

ENV BITBUCKET_HOME=/var/atlassian/bitbucket \
    BITBUCKET_INSTALL=/opt/bitbucket \
    BITBUCKET_PROXY_NAME= \
    BITBUCKET_PROXY_PORT= \
    BITBUCKET_PROXY_SCHEME=

RUN export MYSQL_DRIVER_VERSION=5.1.38 && \
    export POSTGRESQL_DRIVER_VERSION=9.4.1207 && \
    export CONTAINER_USER=bitbucket &&  \
    export CONTAINER_GROUP=bitbucket &&  \
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP &&  \
    adduser -u $CONTAINER_UID \
            -G $CONTAINER_GROUP \
            -h /home/$CONTAINER_USER \
            -s /bin/bash \
            -S $CONTAINER_USER &&  \
    apk add --update \
      ca-certificates \
      gzip \
      git \
      perl \
      wget &&  \
    apk add xmlstarlet --update-cache \
      --repository \
      http://dl-3.alpinelinux.org/alpine/edge/testing/ \
      --allow-untrusted &&  \
    wget -O /tmp/bitbucket.tar.gz https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz && \
    tar zxf /tmp/bitbucket.tar.gz -C /tmp && \
    mv /tmp/atlassian-bitbucket-${BITBUCKET_VERSION} /tmp/bitbucket && \
    mkdir -p ${BITBUCKET_HOME} && \
    mkdir -p /opt && \
    mv /tmp/bitbucket /opt/bitbucket && \
    # Install database drivers
    rm -f                                               \
      ${BITBUCKET_INSTALL}/lib/mysql-connector-java*.jar &&  \
    wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz                                              \
      http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz                                              \
      -C /tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar     \
      ${BITBUCKET_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar                                &&  \
    rm -f ${BITBUCKET_INSTALL}/lib/postgresql-*.jar                                                                &&  \
    wget -O ${BITBUCKET_INSTALL}/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar                                       \
      https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar && \
    # Adding letsencrypt-ca to truststore
    wget -O /home/${CONTAINER_USER}/letsencryptauthorityx1.der https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -noprompt -importcert -file /home/${CONTAINER_USER}/letsencryptauthorityx1.der && \
    rm -f /home/${CONTAINER_USER}/letsencryptauthorityx1.der && \
    # Install atlassian ssl tool
    wget -O /home/${CONTAINER_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/SSLPoke.class && \
    # Container user permissions
    chown -R bitbucket:bitbucket /home/${CONTAINER_USER} && \
    chown -R bitbucket:bitbucket ${BITBUCKET_HOME} && \
    chmod -R u=rwx,g=rwx,o=-rwx ${BITBUCKET_INSTALL} && \
    chown -R bitbucket:bitbucket ${BITBUCKET_INSTALL} && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      gzip \
      wget &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

USER bitbucket
WORKDIR /var/atlassian/bitbucket
VOLUME ["/var/atlassian/bitbucket"]
EXPOSE 7990 7999
COPY imagescripts /home/bitbucket
ENTRYPOINT ["/home/bitbucket/docker-entrypoint.sh"]
CMD ["bitbucket"]
