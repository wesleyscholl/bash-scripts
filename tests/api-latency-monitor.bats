#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/api-latency-monitor.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines threshold variable" {
    run grep -q "THRESHOLD_MS=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script rejects invalid threshold" {
    run "$SCRIPT_PATH" https://example.com bad
    [ "$status" -eq 1 ]
}
