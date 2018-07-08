#!/bin/bash

IMAGE_LABEL=$*
IMAGE_NAME=shkreza/lock-backend
if [ -z "$IMAGE_LABEL" ]; then
    IMAGE_NAME_WITH_LABEL=shkreza/lock-backend
else
    IMAGE_NAME_WITH_LABEL=shkreza/lock-backend:$*
fi

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)
DOCKER_DIR_ABSOLUATE=$(cd $BIN_DIR_ABSOLUATE/../backend/docker; pwd)

echo "Building dockerfile in: $DOCKER_DIR_ABSOLUATE"
echo "Producing image: $IMAGE_NAME"

(
cd $DOCKER_DIR_ABSOLUATE;
docker build -t $IMAGE_NAME:latest .;
)
docker tag $IMAGE_NAME:latest $IMAGE_NAME_WITH_LABEL
