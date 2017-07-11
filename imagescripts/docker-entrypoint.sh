#!/bin/bash
#
# A helper script for ENTRYPOINT.
#
# If first CMD argument is 'bitbucket', then the script will start jira
# If CMD argument is overriden and not 'bitbucket', then the user wants to run
# his own process.

set -e

[[ ${DEBUG} == true ]] && set -x

function updateBitbucketProperties() {
  local propertyfile=$1
  local propertyname=$2
  local propertyvalue=$3
  set +e
  grep -q "${propertyname}=" ${propertyfile}
  if [ $? -eq 0 ]; then
    set -e
    sed -i "s/\(${propertyname/./\\.}=\).*\$/\1\\${propertyvalue}/" ${propertyfile}
  else
    set -e
    echo "${propertyname}=${propertyvalue}" >> ${propertyfile}
  fi
}

function processBitbucketProxySettings() {
  if [ -n "${BITBUCKET_CONTEXT_PATH}" ] || [ -n "${BITBUCKET_PROXY_NAME}" ] || [ -n "${BITBUCKET_PROXY_PORT}" ] || [ -n "${BITBUCKET_DELAYED_START}" ]; then
    if [ ! -f ${BITBUCKET_HOME}/bitbucket.properties ]; then
      touch ${BITBUCKET_HOME}/bitbucket.properties
    fi
  fi

  if [ -n "${BITBUCKET_CONTEXT_PATH}" ]; then
    updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.context-path" ${BITBUCKET_CONTEXT_PATH}
  fi

  if [ -n "${BITBUCKET_PROXY_NAME}" ]; then
    updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.proxy-name" ${BITBUCKET_PROXY_NAME}
  fi

  if [ -n "${BITBUCKET_PROXY_PORT}" ]; then
    updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.proxy-port" ${BITBUCKET_PROXY_PORT}
  fi

  if [ -n "${BITBUCKET_PROXY_SCHEME}" ]; then
    if [ "${BITBUCKET_PROXY_SCHEME}" = 'https' ]; then
      local secure="true"
      updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.secure" ${secure}
      updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.scheme" ${BITBUCKET_PROXY_SCHEME}
    else
      local secure="false"
      updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.secure" ${secure}
      updateBitbucketProperties ${BITBUCKET_HOME}/bitbucket.properties "server.scheme" ${BITBUCKET_PROXY_SCHEME}
    fi
  fi
}

if [ -n "${BITBUCKET_DELAYED_START}" ]; then
  sleep ${BITBUCKET_DELAYED_START}
fi

processBitbucketProxySettings

# If there is a 'ssh' directory, copy it to /home/bitbucket/.ssh
if [ -d /var/atlassian/bitbucket/ssh ]; then
  mkdir -p /home/bitbucket/.ssh
  cp -R /var/atlassian/bitbucket/ssh/* /home/bitbucket/.ssh
  chmod -R 700 /home/bitbucket/.ssh
fi

if [ "$1" = 'bitbucket' ] || [ "${1:0:1}" = '-' ]; then
  umask 0027
  exec ${BITBUCKET_INSTALL}/bin/start-bitbucket.sh --no-search -fg
else
  exec "$@"
fi
