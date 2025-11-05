#!/bin/bash

# Variables
SONARQUBE_URL="https://sonarqube.example.com"
PROJECT_KEY="my-project"
SONAR_TOKEN="your-sonar-token"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXX/XXX/XXX"

# Run SonarQube analysis
sonar-scanner \
    -Dsonar.projectKey="$PROJECT_KEY" \
    -Dsonar.host.url="$SONARQUBE_URL" \
    -Dsonar.login="$SONAR_TOKEN"

# Get the quality gate status
STATUS=$(curl -s -u "$SONAR_TOKEN:" "$SONARQUBE_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY" | jq -r '.projectStatus.status')

# Notify Slack
curl -X POST -H 'Content-type: application/json' \
     --data "{
        \"text\": \"SonarQube analysis completed for project $PROJECT_KEY. Quality Gate Status: $STATUS\"
     }" \
     "$SLACK_WEBHOOK_URL"

echo "SonarQube analysis status sent to Slack."
