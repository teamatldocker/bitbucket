#!/bin/bash
#
# A helper script for ENTRYPOINT.
#
# If first CMD argument is 'bitbucket', then the script will start jira
# If CMD argument is overriden and not 'bitbucket', then the user wants to run
# his own process.

set -o errexit

function processBitbucketProxySettings() {
  if [ -n "${BITBUCKET_PROXY_NAME}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${BITBUCKET_PROXY_NAME}" ${BITBUCKET_INSTALL}/conf/server.xml
  fi

  if [ -n "${BITBUCKET_PROXY_PORT}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${BITBUCKET_PROXY_PORT}" ${BITBUCKET_INSTALL}/conf/server.xml
  fi

  if [ -n "${BITBUCKET_PROXY_SCHEME}" ]; then
    xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${BITBUCKET_PROXY_SCHEME}" ${BITBUCKET_INSTALL}/conf/server.xml
  fi
}

if [ -n "${BITBUCKET_DELAYED_START}" ]; then
  sleep ${BITBUCKET_DELAYED_START}
fi

processBitbucketProxySettings

if [ "$1" = 'bitbucket' ] || [ "${1:0:1}" = '-' ]; then
  exec ${BITBUCKET_INSTALL}/bin/catalina.sh run -fg
else
  exec "$@"
fi
