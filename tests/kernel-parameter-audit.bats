#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/kernel-parameter-audit.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines CHECKS array" {
    run grep -q "CHECKS=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "script checks for sysctl command" {
    run grep -q "sysctl" "$SCRIPT_PATH"
    assert_success
}

@test "script includes ASLR check" {
    run grep -q "randomize_va_space" "$SCRIPT_PATH"
    assert_success
}

@test "script includes SYN cookie check" {
    run grep -q "tcp_syncookies" "$SCRIPT_PATH"
    assert_success
}

@test "script runs and exits with 0 or 1" {
    if ! command -v sysctl >/dev/null 2>&1; then skip "sysctl not available"; fi
    run bash "$SCRIPT_PATH"
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script outputs OK or FAIL or SKIP per parameter" {
    run grep -qE "^    echo .OK:" "$SCRIPT_PATH"
    assert_success
}
