#!/usr/bin/env bats

# Tests for sonarqube-slack-notify.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/sonarqube-slack-notify.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "jq command available" {
    command -v jq || skip "jq not installed"
}

@test "sonar-scanner command available" {
    command -v sonar-scanner || skip "sonar-scanner not installed"
}

@test "script defines SonarQube URL variable" {
    run grep -q "SONARQUBE_URL=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines project key variable" {
    run grep -q "PROJECT_KEY=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines Sonar token variable" {
    run grep -q "SONAR_TOKEN=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines Slack webhook URL variable" {
    run grep -q "SLACK_WEBHOOK_URL=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script runs sonar-scanner" {
    run grep -q "sonar-scanner" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets project key parameter" {
    run grep -q "sonar.projectKey" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets host URL parameter" {
    run grep -q "sonar.host.url" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets login parameter" {
    run grep -q "sonar.login" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script fetches quality gate status" {
    run grep -q "STATUS=.*curl.*qualitygates" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses jq to parse JSON" {
    run grep -q "jq -r" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes authentication in API call" {
    run grep -q "\-u.*SONAR_TOKEN" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends notification to Slack" {
    run grep -q "curl -X POST.*SLACK_WEBHOOK_URL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends JSON payload to Slack" {
    run grep -q "Content-type: application/json" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes status in Slack message" {
    run grep -q "Quality Gate Status" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "status sent to Slack" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
