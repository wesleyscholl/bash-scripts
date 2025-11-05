#!/bin/bash

# Usage: ./scale_deployment.sh <namespace> <deployment_name> <replicas>
NAMESPACE=$1
DEPLOYMENT_NAME=$2
REPLICAS=$3

if [[ -z "$NAMESPACE" || -z "$DEPLOYMENT_NAME" || -z "$REPLICAS" ]]; then
    echo "Usage: $0 <namespace> <deployment_name> <replicas>"
    exit 1
fi

# Scale the deployment
kubectl scale deployment "$DEPLOYMENT_NAME" --replicas="$REPLICAS" -n "$NAMESPACE"

echo "Scaled deployment '$DEPLOYMENT_NAME' in namespace '$NAMESPACE' to $REPLICAS replicas."
