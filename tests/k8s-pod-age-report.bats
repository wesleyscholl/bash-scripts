#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/k8s-pod-age-report.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script checks kubectl dependency" {
    run grep -q "command -v kubectl" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script rejects invalid hours" {
    run "$SCRIPT_PATH" bad
    [ "$status" -eq 1 ]
}
