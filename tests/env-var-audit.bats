#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/env-var-audit.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines vars array" {
    run grep -q "VARS=(" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script fails when required var missing" {
    unset TEST_MISSING_VAR
    run "$SCRIPT_PATH" TEST_MISSING_VAR
    [ "$status" -eq 1 ]
}
