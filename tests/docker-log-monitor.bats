#!/usr/bin/env bats

# Tests for docker-log-monitor.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/docker-log-monitor.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "docker command available" {
    command -v docker || skip "docker not installed"
}

@test "curl command available" {
    command -v curl
}

@test "script defines container name variable" {
    run grep -q "CONTAINER_NAME=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines error pattern variable" {
    run grep -q "ERROR_PATTERN=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines API key variable" {
    run grep -q "OPSGENIE_API_KEY=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines alert message variable" {
    run grep -q "ALERT_MESSAGE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script monitors docker logs" {
    run grep -q "docker logs -f" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reads log output in loop" {
    run grep -q "while read" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script matches error pattern" {
    run grep -q "\[\[.*=~.*ERROR_PATTERN" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends alert via API" {
    run grep -q "curl -X POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses OpsGenie API endpoint" {
    run grep -q "api.opsgenie.com" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes authorization header" {
    run grep -q "Authorization: GenieKey" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends JSON payload" {
    run grep -q "Content-Type: application/json" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides alert confirmation" {
    run grep -q "Alert sent for error" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
