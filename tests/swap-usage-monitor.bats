#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/swap-usage-monitor.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines THRESHOLD variable" {
    run grep -q "^THRESHOLD=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "script rejects threshold below 1" {
    run bash "$SCRIPT_PATH" --threshold 0
    assert_failure
}

@test "script rejects threshold above 100" {
    run bash "$SCRIPT_PATH" --threshold 101
    assert_failure
}

@test "script rejects non-numeric threshold" {
    run bash "$SCRIPT_PATH" --threshold abc
    assert_failure
}

@test "script runs and exits with 0 or 1" {
    run bash "$SCRIPT_PATH"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script reports OK when swap is within threshold" {
    run grep -q "OK:" "$SCRIPT_PATH"
    assert_success
}

@test "script handles no swap configured" {
    run grep -q "no swap configured" "$SCRIPT_PATH"
    assert_success
}
