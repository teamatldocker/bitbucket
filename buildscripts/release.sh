#!/bin/bash

#------------------
# CONTAINER VARIABLES
#------------------
export BITBUCKET_VERSION=5.8.1

docker build -t blacklabelops/bitbucket .
docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
docker push blacklabelops/bitbucket
docker tag blacklabelops/bitbucket:${BITBUCKET_VERSION} blacklabelops/bitbucket:${BITBUCKET_VERSION}
docker push blacklabelops/bitbucket:${BITBUCKET_VERSION}
