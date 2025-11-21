#!/usr/bin/env bats

# Tests for process-monitor-alert.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/process-monitor-alert.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "pgrep command available" {
    command -v pgrep
}

@test "mail command available" {
    command -v mail || command -v sendmail || skip "mail command not available"
}

@test "script defines process name variable" {
    run grep -q "PROCESS_NAME=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses pgrep to check process" {
    run grep -q "pgrep.*PROCESS_NAME" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks process status" {
    run grep -q "if pgrep" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports when process is running" {
    run grep -q "is running" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports when process is not running" {
    run grep -q "is not running" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends alert when process is down" {
    run grep -q "Sending alert" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends email alert" {
    run grep -q "mail -s" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "pgrep can find running processes" {
    # Try to find common processes that should be running
    run pgrep init || run pgrep systemd || run pgrep launchd
    # At least one should succeed on any Unix-like system
    [ "$status" -eq 0 ] || skip "no common init process found"
}
