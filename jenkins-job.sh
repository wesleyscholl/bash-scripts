#!/bin/bash

# Usage: ./trigger_jenkins_job.sh <jenkins_url> <job_name> <token> <param_key> <param_value>
JENKINS_URL=$1
JOB_NAME=$2
TOKEN=$3
PARAM_KEY=$4
PARAM_VALUE=$5

if [[ -z "$JENKINS_URL" || -z "$JOB_NAME" || -z "$TOKEN" || -z "$PARAM_KEY" || -z "$PARAM_VALUE" ]]; then
    echo "Usage: $0 <jenkins_url> <job_name> <token> <param_key> <param_value>"
    exit 1
fi

# Trigger the Jenkins job
curl -X POST "$JENKINS_URL/job/$JOB_NAME/buildWithParameters" \
     --user "your-username:your-api-token" \
     --data-urlencode "token=$TOKEN" \
     --data-urlencode "$PARAM_KEY=$PARAM_VALUE"

echo "Triggered Jenkins job '$JOB_NAME' with parameter '$PARAM_KEY=$PARAM_VALUE'."
