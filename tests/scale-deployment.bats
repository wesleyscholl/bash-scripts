#!/usr/bin/env bats

# Tests for scale-deployment.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/scale-deployment.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "kubectl command available" {
    command -v kubectl || skip "kubectl not installed"
}

@test "script validates argument count" {
    run grep -q "if \[\[.*-z.*NAMESPACE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains usage message" {
    run grep -q "Usage:" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses namespace variable" {
    run grep -q "NAMESPACE=\$1" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses deployment name variable" {
    run grep -q "DEPLOYMENT_NAME=\$2" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses replicas variable" {
    run grep -q "REPLICAS=\$3" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script calls kubectl scale" {
    run grep -q "kubectl scale deployment" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses replicas parameter" {
    run grep -q "\-\-replicas" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses namespace parameter" {
    run grep -q "\-n.*NAMESPACE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides confirmation message" {
    run grep -q "Scaled deployment" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
