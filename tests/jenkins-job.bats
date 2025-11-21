#!/usr/bin/env bats

# Tests for jenkins-job.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/jenkins-job.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script validates argument count" {
    run grep -q "if \[\[.*-z" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains usage message" {
    run grep -q "Usage:" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses POST method" {
    run grep -q "POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains Jenkins URL variable" {
    run grep -q "JENKINS_URL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains job name variable" {
    run grep -q "JOB_NAME" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains token variable" {
    run grep -q "TOKEN" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses buildWithParameters endpoint" {
    run grep -q "buildWithParameters" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script performs URL encoding" {
    run grep -q "data-urlencode" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes authentication" {
    run grep -q "\-\-user" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides feedback on job trigger" {
    run grep -q "echo.*Triggered" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
