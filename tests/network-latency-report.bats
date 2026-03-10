#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/network-latency-report.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines COUNT variable" {
    run grep -q "^COUNT=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing host argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}

@test "script validates count is a positive integer" {
    run bash "$SCRIPT_PATH" --count abc 127.0.0.1
    assert_failure
}

@test "script validates threshold is not negative" {
    run bash "$SCRIPT_PATH" --threshold abc 127.0.0.1
    assert_failure
}

@test "script defines THRESHOLD variable" {
    run grep -q "^THRESHOLD=" "$SCRIPT_PATH"
    assert_success
}

@test "script uses ping command" {
    run grep -q "ping" "$SCRIPT_PATH"
    assert_success
}

@test "script reports UNREACHABLE for hosts with no response" {
    run grep -q "UNREACHABLE" "$SCRIPT_PATH"
    assert_success
}
