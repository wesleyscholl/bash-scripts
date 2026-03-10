#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/uptime-reporter.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines REBOOT_HISTORY variable" {
    run grep -q "^REBOOT_HISTORY=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "script rejects non-numeric reboots value" {
    run bash "$SCRIPT_PATH" --reboots abc
    assert_failure
}

@test "script uses uptime command" {
    run grep -q "uptime" "$SCRIPT_PATH"
    assert_success
}

@test "script reports load average" {
    run grep -q "Load avg" "$SCRIPT_PATH"
    assert_success
}

@test "script shows recent reboots section" {
    run grep -q "Recent reboots" "$SCRIPT_PATH"
    assert_success
}

@test "script runs successfully" {
    run bash "$SCRIPT_PATH"
    assert_success
    assert_output --partial "Uptime:"
}
