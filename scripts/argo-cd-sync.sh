#!/bin/bash

# Variables
ARGOCD_SERVER="argocd.example.com"
ARGOCD_APP="my-app"
ARGOCD_TOKEN="your-argocd-token"

# Trigger the sync
curl -X POST "https://$ARGOCD_SERVER/api/v1/applications/$ARGOCD_APP/sync" \
     -H "Authorization: Bearer $ARGOCD_TOKEN"

echo "Triggered sync for application '$ARGOCD_APP' in Argo CD."
