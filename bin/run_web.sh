#!/bin/bash

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)

WEB_CONTAINER_HOST_IP=$(docker-machine ip dev)
if [ -z "$WEB_CONTAINER_HOST_IP" ]; then
    echo "ERROR: Could not get docker host IP."
    exit 0
fi

WEB_IMAGE_NAME="shkreza/lock-web:latest"
WEB_CONTAINER_NAME="lock-web"
WEB_CONTAINER_PORT=443
WEB_HOST_PORT=443
SECRETS_TLS=$(cd $BIN_DIR_ABSOLUATE/../secrets/lock-backend/tls-secrets/; pwd)
SECRETS_TLS_MOUNT="/secrets/lock-web/tls-secrets"

# STOP/REMOVE RUNNING WEB CONTAINER
docker stop $WEB_CONTAINER_NAME 2> /dev/null
docker rm $WEB_CONTAINER_NAME 2> /dev/null

# RUN DOCKER IMAGE
docker run \
    --name "$WEB_CONTAINER_NAME" \
    -it \
    --publish $WEB_HOST_PORT:$WEB_CONTAINER_PORT \
    --volume $SECRETS_TLS:$SECRETS_TLS_MOUNT \
    --volume $SECRETS_IOT_HUB_CONNECTIONSTRING:$SECRETS_IOT_HUB_CONNECTIONSTRING_MOUNT \
    $WEB_IMAGE_NAME
