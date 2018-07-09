#!/bin/bash

BIN_DIR=$(dirname $0)
BIN_DIR_ABSOLUATE=$(cd $BIN_DIR; pwd)
SECRETS_ROOT=$(cd $BIN_DIR_ABSOLUATE/../secrets/; pwd)

# GCP BACKEND
GCP_SECRETS_ROOT="$SECRETS_ROOT/gcp-secrets"

if [ ! -d "$GCP_SECRETS_ROOT" ]; then
    echo "Missing secrets folder at: $GCP_SECRETS_ROOT."
    exit 1
fi

kubectl create secret generic gcp-secrets --dry-run --from-file=$GCP_SECRETS_ROOT -o yaml | kubectl apply -f -

