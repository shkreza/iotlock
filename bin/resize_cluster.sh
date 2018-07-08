#! /bin/bash

CLUSTER_NAME="cluster-1"
CLUSTER_ZONE="us-central1-a"
PROJECT_NAME="iot-api-gateway"
NODE_POOL="default-pool"

SIZE=$*
if [ -z "$SIZE" ]; then
    echo "No size is provided.";
    exit 1
fi

gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_NAME

gcloud container clusters resize $CLUSTER_NAME --size=$SIZE --node-pool=$NODE_POOL
