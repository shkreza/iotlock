#!/bin/bash

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)
SECRETS_ROOT=$(cd $BIN_DIR_ABSOLUATE/../secrets/; pwd)

# BACKEND
BACKEND_TLS_SECRETS_ROOT="$SECRETS_ROOT/tls-backend"
KEY_FILE="$BACKEND_TLS_SECRETS_ROOT/tls.key"
CRT_FILE="$BACKEND_TLS_SECRETS_ROOT/tls.CRT"

if [ ! -f "$KEY_FILE" ]; then
    echo "Missing key file at: $KEY_FILE."
    exit 1
fi

if [ ! -f "$CRT_FILE" ]; then
    echo "Missing cert file at: $CRT_FILE."
    exit 1
fi

kubectl create secret tls tls-secrets --dry-run --key=$KEY_FILE --cert=$CRT_FILE -o yaml | kubectl apply -f -

# ESP BACKEND
ESP_BACKEND_TLS_SECRETS_ROOT="$SECRETS_ROOT/tls-esp-backend"
ESP_KEY_FILE="$ESP_BACKEND_TLS_SECRETS_ROOT/nginx.key"
ESP_CRT_FILE="$ESP_BACKEND_TLS_SECRETS_ROOT/nginx.crt"

if [ ! -f "$ESP_KEY_FILE" ]; then
    echo "Missing nginx key file at: $ESP_KEY_FILE."
    exit 1
fi

if [ ! -f "$ESP_CRT_FILE" ]; then
    echo "Missing nginx cert file at: $ESP_CRT_FILE."
    exit 1
fi

kubectl create secret generic tls-esp-secrets --dry-run --from-file=$ESP_BACKEND_TLS_SECRETS_ROOT -o yaml | kubectl apply -f -
