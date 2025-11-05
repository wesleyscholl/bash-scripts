#!/bin/bash

# Variables
NAMESPACE="test-namespace"

# Confirm namespace deletion
read -p "Are you sure you want to delete all resources in the namespace '$NAMESPACE'? (yes/no): " CONFIRMATION
if [[ "$CONFIRMATION" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

# Delete all resources in the namespace
kubectl delete all --all -n "$NAMESPACE"

# Delete the namespace itself
kubectl delete namespace "$NAMESPACE"

echo "Namespace '$NAMESPACE' and all its resources have been deleted."
