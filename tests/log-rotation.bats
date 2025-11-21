#!/usr/bin/env bats

# Tests for log-rotation.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/log-rotation.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/log_rotation_test"
    export TEST_LOG="${TEST_DIR}/test.log"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "stat command available" {
    command -v stat
}

@test "date command available" {
    command -v date
}

@test "script defines log file variable" {
    run grep -q "LOG_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines max size variable" {
    run grep -q "MAX_SIZE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines backup directory variable" {
    run grep -q "BACKUP_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script generates timestamp" {
    run grep -q "TIMESTAMP=.*date" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks if log file exists" {
    run grep -q "if \[ -f.*LOG_FILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script gets file size" {
    run grep -q "FILE_SIZE=.*stat" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script compares file size with threshold" {
    run grep -q "if \[.*FILE_SIZE.*MAX_SIZE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script creates backup directory" {
    run grep -q "mkdir -p.*BACKUP_DIR" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script moves log file with timestamp" {
    run grep -q "mv.*LOG_FILE.*TIMESTAMP" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script creates new empty log file" {
    run grep -q "touch.*LOG_FILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets file permissions" {
    run grep -q "chmod 644" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "can create test log file" {
    echo "test log content" > "$TEST_LOG"
    [ -f "$TEST_LOG" ]
}

@test "can get file size" {
    echo "test" > "$TEST_LOG"
    # Use -f on macOS, -c on Linux
    if stat -f%z "$TEST_LOG" &>/dev/null; then
        run stat -f%z "$TEST_LOG"
    else
        run stat -c%s "$TEST_LOG"
    fi
    [ "$status" -eq 0 ]
}

@test "timestamp format is valid" {
    timestamp=$(date '+%Y%m%d%H%M%S')
    [[ "$timestamp" =~ ^[0-9]{14}$ ]]
}
