#!/usr/bin/env bats

# Tests for log-monitor.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/log-monitor.sh"
    export TEST_LOG="${BATS_TEST_TMPDIR}/test.log"
    echo "INFO: Normal log line" > "$TEST_LOG"
    echo "ERROR: Something went wrong" >> "$TEST_LOG"
    echo "WARNING: Potential issue" >> "$TEST_LOG"
}

teardown() {
    rm -f "$TEST_LOG"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "tail command available" {
    command -v tail
}

@test "grep command available" {
    command -v grep
}

@test "script defines email enabled variable" {
    run grep -q "EMAIL_ENABLED=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines color codes" {
    run grep -q "RED=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has show_usage function" {
    run grep -q "show_usage()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has send_email function" {
    run grep -q "send_email()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has process_log_line function" {
    run grep -q "process_log_line()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts email flag" {
    run grep -q "\-e|\-\-email" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts static flag" {
    run grep -q "\-s|\-\-static" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts help flag" {
    run grep -q "\-h|\-\-help" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script validates log file exists" {
    run grep -q "if \[ ! -f.*LOG_FILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script validates log file is readable" {
    run grep -q "if \[ ! -r.*LOG_FILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for mail command" {
    run grep -q "command -v mail" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses tail -f for real-time monitoring" {
    run grep -q "tail -f" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script can scan existing content" {
    run grep -q "Scanning existing log content" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "test log file exists" {
    [ -f "$TEST_LOG" ]
}

@test "can grep ERROR keyword from test log" {
    run grep "ERROR" "$TEST_LOG"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ERROR: Something went wrong" ]]
}

@test "can grep WARNING keyword from test log" {
    run grep "WARNING" "$TEST_LOG"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "WARNING: Potential issue" ]]
}
