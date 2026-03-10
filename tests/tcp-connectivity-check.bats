#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/tcp-connectivity-check.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines host and port variables" {
    run grep -q "HOST=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
    run grep -q "PORT=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script validates numeric args" {
    run "$SCRIPT_PATH" example.com bad 5
    [ "$status" -eq 1 ]
}
