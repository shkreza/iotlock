#!/bin/bash

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)

BACKEND_CONTAINER_HOST_IP=$(docker-machine ip dev)
if [ -z "$BACKEND_CONTAINER_HOST_IP" ]; then
    echo "ERROR: Could not get docker host IP."
    exit 0
fi

ESP_IMAGE_NAME="gcr.io/endpoints-release/endpoints-runtime:1"
ESP_CONTAINER_NAME="esp"
GCP_SERVICE_NAME="lock.endpoints.iot-api-gateway.cloud.goog"
ESP_CONTAINER_PORT=443
ESP_HOST_PORT=443
SECRET_SA_LOCK_BACKEND_FILENAME="sa-lock-esp.json"
SECRET_SA_LOCK_BACKEND_DIR=$(cd $BIN_DIR_ABSOLUATE/../secrets/lock-backend/gcp-secrets/; pwd)
SECRET_SA_LOCK_BACKEND_MOUNT="/secrets/lock-backend/gcp-secrets"
SECRET_SA_LOCK_BACKEND_PATH="$SECRET_SA_LOCK_BACKEND_MOUNT/$(basename $SECRET_SA_LOCK_BACKEND_FILENAME)"
SECRET_TLS_ESP=$(cd $BIN_DIR_ABSOLUATE/../secrets/lock-backend/tls-esp-secrets/; pwd)
SECRET_TLS_ESP_MOUNT="/etc/nginx/ssl"

BACKEND_IMAGE_NAME="shkreza/lock-backend:latest"
BACKEND_CONTAINER_NAME="lock-backend"
BACKEND_CONTAINER_PORT=4443
BACKEND_HOST_PORT=4443
SECRETS_TLS=$(cd $BIN_DIR_ABSOLUATE/../secrets/lock-backend/tls-secrets/; pwd)
SECRETS_TLS_MOUNT="/secrets/lock-backend/tls-secrets"
SECRETS_IOT_HUB_CONNECTIONSTRING=$(cd $BIN_DIR_ABSOLUATE/../secrets/lock-backend/iot-hub-connectionstring/; pwd)
SECRETS_IOT_HUB_CONNECTIONSTRING_MOUNT="/secrets/lock-backend/iot-hub-connectionstring"

# PULL ESP DOCKER
gcloud docker -- pull $ESP_IMAGE_NAME 

# STOP/REMOVE RUNNING ESP CONTAINER
docker stop $ESP_CONTAINER_NAME 2> /dev/null
docker rm $ESP_CONTAINER_NAME 2> /dev/null

# RUN ESP DOCKER
docker run \
    --name $ESP_CONTAINER_NAME \
    --detach \
    --publish $ESP_HOST_PORT:$ESP_CONTAINER_PORT \
    --volume $SECRET_TLS_ESP:$SECRET_TLS_ESP_MOUNT \
    --volume $SECRET_SA_LOCK_BACKEND_DIR:$SECRET_SA_LOCK_BACKEND_MOUNT \
    $ESP_IMAGE_NAME \
    --service=$GCP_SERVICE_NAME \
    --rollout_strategy=managed \
    --ssl_port=443 \
    --backend=https://$BACKEND_CONTAINER_HOST_IP:$BACKEND_HOST_PORT \
    --service_account_key=$SECRET_SA_LOCK_BACKEND_PATH

# STOP/REMOVE RUNNING ESP CONTAINER
docker stop $BACKEND_CONTAINER_NAME 2> /dev/null
docker rm $BACKEND_CONTAINER_NAME 2> /dev/null

# RUN DOCKER IMAGE
docker run \
    --name "$BACKEND_CONTAINER_NAME" \
    -it \
    --publish $BACKEND_HOST_PORT:$BACKEND_CONTAINER_PORT \
    --volume $SECRETS_TLS:$SECRETS_TLS_MOUNT \
    --volume $SECRETS_IOT_HUB_CONNECTIONSTRING:$SECRETS_IOT_HUB_CONNECTIONSTRING_MOUNT \
    $BACKEND_IMAGE_NAME
