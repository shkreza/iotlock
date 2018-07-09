#!/bin/bash

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)
SECRETS_ROOT=$(cd $BIN_DIR_ABSOLUATE/../secrets/; pwd)

# IOT_HUB BACKEND
IOT_HUB_SECRETS_ROOT="$SECRETS_ROOT/iot-hub-connectionstring"

if [ ! -d "$IOT_HUB_SECRETS_ROOT" ]; then
    echo "Missing secrets folder at: $IOT_HUB_SECRETS_ROOT."
    exit 1
fi

kubectl create secret generic iot-hub-secrets --dry-run --from-file=$IOT_HUB_SECRETS_ROOT -o yaml | kubectl apply -f -


