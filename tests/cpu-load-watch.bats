#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/cpu-load-watch.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines threshold variable" {
    run grep -q "THRESHOLD=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script rejects non-numeric threshold" {
    run "$SCRIPT_PATH" not-a-number
    [ "$status" -eq 1 ]
}
